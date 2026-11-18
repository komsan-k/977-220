`timescale 1ns / 1ps

// Self-checking testbench for ann_fpga_top with PARALLEL=1.
// Exercises the FPGA-level start_button synchronizer and the parallel MAC core.
module tb_ann_parallel_top;

    reg clk;
    reg rst;
    reg start_button;
    reg A;
    reg B;

    wire H1;
    wire H2;
    wire Y;
    wire busy;

    integer pass_count;
    integer latency_cycles;
    integer wait_cycles;

    // 100 MHz FPGA clock: 10 ns period.
    initial clk = 1'b0;
    always #5 clk = ~clk;

    ann_fpga_top #(.PARALLEL(1)) dut (
        .clk(clk),
        .rst(rst),
        .start_button(start_button),
        .A(A),
        .B(B),
        .H1(H1),
        .H2(H2),
        .Y(Y),
        .busy(busy)
    );

    task run_case;
        input a_in;
        input b_in;
        reg exp_h1;
        reg exp_h2;
        reg exp_y;
        begin
            // Hidden neurons implement OR and NAND; output implements XOR.
            exp_h1 = a_in | b_in;
            exp_h2 = ~(a_in & b_in);
            exp_y  = a_in ^ b_in;

            // Change inputs away from the active clock edge.
            @(negedge clk);
            A = a_in;
            B = b_in;
            start_button = 1'b1;

            // One full clock cycle is sufficient for the two-flop synchronizer.
            @(negedge clk);
            start_button = 1'b0;

            // Allow time for start_button synchronization and busy assertion.
            wait_cycles = 0;
            while ((busy !== 1'b1) && (wait_cycles < 10)) begin
                @(posedge clk);
                #1;
                wait_cycles = wait_cycles + 1;
            end
            if (busy !== 1'b1)
                $fatal(1, "TIMEOUT: busy did not assert for A=%b B=%b", A, B);

            // Measure core latency from busy assertion to busy deassertion.
            // This excludes start_button synchronizer delay.
            latency_cycles = 0;
            while ((busy === 1'b1) && (latency_cycles < 20)) begin
                @(posedge clk);
                #1;
                latency_cycles = latency_cycles + 1;
            end
            if (busy !== 1'b0)
                $fatal(1, "TIMEOUT: parallel MAC did not finish for A=%b B=%b", A, B);

            if (H1 !== exp_h1 || H2 !== exp_h2 || Y !== exp_y)
                $fatal(1,
                    "FAIL A=%b B=%b: got H1=%b H2=%b Y=%b; expected H1=%b H2=%b Y=%b",
                    A, B, H1, H2, Y, exp_h1, exp_h2, exp_y);

            // Eight clock cycles are expected from the supplied ann_mac_parallel RTL.
            if (latency_cycles != 8)
                $fatal(1, "FAIL A=%b B=%b: expected 8 busy cycles, measured %0d",
                       A, B, latency_cycles);

            pass_count = pass_count + 1;
            $display("PASS A=%b B=%b | H1=%b H2=%b Y=%b | latency=%0d cycles",
                     A, B, H1, H2, Y, latency_cycles);

            // Keep start low long enough to re-arm the edge detector.
            repeat (2) @(negedge clk);
        end
    endtask

    initial begin
        rst = 1'b1;
        start_button = 1'b0;
        A = 1'b0;
        B = 1'b0;
        pass_count = 0;

        repeat (4) @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        $display("Testing ann_fpga_top with PARALLEL=1");
        run_case(1'b0, 1'b0);
        run_case(1'b0, 1'b1);
        run_case(1'b1, 1'b0);
        run_case(1'b1, 1'b1);

        if (pass_count != 4)
            $fatal(1, "Only %0d of 4 cases passed", pass_count);

        $display("ALL 4 XOR INPUT CASES PASSED (parallel MAC)");
        $finish;
    end

endmodule
