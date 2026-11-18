`timescale 1ns / 1ps

// Test the actual FPGA wrapper for BOTH architectures.
// PARALLEL=0: sequential/shared MAC
// PARALLEL=1: layer-parallel MAC
module tb_ann_compare;

    reg clk;
    reg rst;
    reg start_button;
    reg A;
    reg B;

    wire hs1, hs2, ys, busy_seq;
    wire hp1, hp2, yp, busy_par;

    // 100 MHz clock (10 ns period)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    ann_fpga_top #(.PARALLEL(0)) dut_seq (
        .clk(clk), .rst(rst), .start_button(start_button),
        .A(A), .B(B),
        .H1(hs1), .H2(hs2), .Y(ys), .busy(busy_seq)
    );

    ann_fpga_top #(.PARALLEL(1)) dut_par (
        .clk(clk), .rst(rst), .start_button(start_button),
        .A(A), .B(B),
        .H1(hp1), .H2(hp2), .Y(yp), .busy(busy_par)
    );

    integer case_id;
    integer cycles;
    integer seq_latency;
    integer par_latency;
    reg seq_seen_busy;
    reg par_seen_busy;
    reg seq_finished;
    reg par_finished;
    reg expected_y;
    reg expected_h1;
    reg expected_h2;

    initial begin
        rst          = 1'b1;
        start_button = 1'b0;
        A            = 1'b0;
        B            = 1'b0;

        // Reset both wrappers and their start-button synchronizers.
        repeat (4) @(negedge clk);
        rst = 1'b0;
        repeat (2) @(negedge clk);

        $display("------------------------------------------------------------");
        $display("TEST ann_fpga_top: sequential MAC vs. parallel MAC");
        $display("------------------------------------------------------------");

        for (case_id = 0; case_id < 4; case_id = case_id + 1) begin
            // Set inputs before requesting a new inference.
            @(negedge clk);
            A = case_id[1];
            B = case_id[0];
            expected_y  = A ^ B;
            expected_h1 = A | B;       // Hidden neuron 1: OR
            expected_h2 = ~(A & B);    // Hidden neuron 2: NAND

            // A one-clock pulse is sufficient for the synchronizer.
            start_button = 1'b1;
            @(negedge clk);
            start_button = 1'b0;

            seq_seen_busy = 1'b0;
            par_seen_busy = 1'b0;
            seq_finished  = 1'b0;
            par_finished  = 1'b0;
            seq_latency   = 0;
            par_latency   = 0;

            // Wait for each core to assert and subsequently deassert busy.
            // This includes the start synchronization delay without
            // mistakenly counting it as MAC computation time.
            for (cycles = 0; cycles < 64 &&
                 !(seq_finished && par_finished); cycles = cycles + 1) begin
                @(negedge clk);
                #1;

                if (!seq_finished) begin
                    if (busy_seq === 1'b1) begin
                        seq_seen_busy = 1'b1;
                        seq_latency = seq_latency + 1;
                    end else if (seq_seen_busy && busy_seq === 1'b0) begin
                        seq_finished = 1'b1;
                    end
                end

                if (!par_finished) begin
                    if (busy_par === 1'b1) begin
                        par_seen_busy = 1'b1;
                        par_latency = par_latency + 1;
                    end else if (par_seen_busy && busy_par === 1'b0) begin
                        par_finished = 1'b1;
                    end
                end
            end

            if (!seq_finished || !par_finished)
                $fatal(1, "TIMEOUT: A=%b B=%b seq_done=%b par_done=%b",
                       A, B, seq_finished, par_finished);

            // Check both outputs against XOR and expected hidden states.
            if (ys !== expected_y || yp !== expected_y ||
                hs1 !== expected_h1 || hp1 !== expected_h1 ||
                hs2 !== expected_h2 || hp2 !== expected_h2)
                $fatal(1,
                    "FAIL A=%b B=%b | seq H1H2Y=%b%b%b | par H1H2Y=%b%b%b | expected=%b%b%b",
                    A, B, hs1, hs2, ys, hp1, hp2, yp,
                    expected_h1, expected_h2, expected_y);

            $display("PASS A=%b B=%b | H1=%b H2=%b Y=%b | seq=%0d cycles, par=%0d cycles",
                     A, B, hs1, hs2, ys, seq_latency, par_latency);

            // Leave time between transactions for easy waveform inspection.
            repeat (3) @(negedge clk);
        end

        $display("------------------------------------------------------------");
        $display("ALL 4 XOR INPUT CASES PASSED FOR BOTH FPGA TOP MODULES");
        $display("NOTE: Latencies are measured busy-high clock cycles.");
        $display("------------------------------------------------------------");
        $finish;
    end

    // Absolute guard against an accidentally stalled simulation.
    initial begin
        #10000;
        $fatal(1, "GLOBAL TIMEOUT");
    end

endmodule
