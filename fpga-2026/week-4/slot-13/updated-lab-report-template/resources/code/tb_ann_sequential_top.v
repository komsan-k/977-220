`timescale 1ns / 1ps

// Self-checking testbench for the actual FPGA top-level module.
// PARALLEL=0 selects the shared/sequential MAC ANN.
module tb_ann_sequential_top;

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

    // Nexys A7 system clock: 100 MHz, 10 ns period.
    initial clk = 1'b0;
    always #5 clk = ~clk;

    ann_fpga_top #(.PARALLEL(0)) dut (
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
        reg expected_h1;
        reg expected_h2;
        reg expected_y;
        begin
            expected_h1 = a_in | b_in;       // Hidden neuron 1: OR
            expected_h2 = ~(a_in & b_in);   // Hidden neuron 2: NAND
            expected_y  = a_in ^ b_in;      // ANN output: XOR

            // Apply inputs and a one-clock-wide start-button pulse.
            // Inputs are driven at falling edges to avoid testbench races.
            @(negedge clk);
            A = a_in;
            B = b_in;
            start_button = 1'b1;
            @(negedge clk);
            start_button = 1'b0;

            // Wait for the FPGA wrapper's 2-FF synchronization and
            // rising-edge detection, then for core busy to assert.
            wait_cycles = 0;
            while ((busy !== 1'b1) && (wait_cycles < 12)) begin
                @(posedge clk);
                #1;
                wait_cycles = wait_cycles + 1;
            end
            if (busy !== 1'b1)
                $fatal(1, "TIMEOUT: busy never asserted for A=%b B=%b", A, B);

            // Count clock edges while the sequential MAC is busy.
            // Start-button synchronization is excluded from this latency.
            latency_cycles = 0;
            while ((busy === 1'b1) && (latency_cycles < 32)) begin
                @(posedge clk);
                #1;
                latency_cycles = latency_cycles + 1;
            end
            if (busy !== 1'b0)
                $fatal(1, "TIMEOUT: sequential MAC never finished for A=%b B=%b", A, B);

            // Compare against expected OR/NAND/XOR truth table.
            if ((H1 !== expected_h1) ||
                (H2 !== expected_h2) ||
                (Y  !== expected_y))
                $fatal(1,
                    "FAIL A=%b B=%b | actual H1=%b H2=%b Y=%b | expected H1=%b H2=%b Y=%b",
                    A, B, H1, H2, Y, expected_h1, expected_h2, expected_y);

            // The supplied ann_mac_seq FSM uses 12 busy-high cycles.
            if (latency_cycles != 12)
                $fatal(1,
                    "FAIL A=%b B=%b | expected 12 busy cycles, measured %0d",
                    A, B, latency_cycles);

            pass_count = pass_count + 1;
            $display("PASS A=%b B=%b | H1=%b H2=%b Y=%b | latency=%0d cycles",
                     A, B, H1, H2, Y, latency_cycles);

            // Ensure start remains low before the next transaction.
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

        $display("--------------------------------------------");
        $display("Testing ann_fpga_top with PARALLEL=0");
        $display("--------------------------------------------");

        run_case(1'b0, 1'b0);
        run_case(1'b0, 1'b1);
        run_case(1'b1, 1'b0);
        run_case(1'b1, 1'b1);

        if (pass_count != 4)
            $fatal(1, "Only %0d of 4 XOR cases passed", pass_count);

        $display("--------------------------------------------");
        $display("ALL 4 XOR INPUT CASES PASSED (sequential MAC)");
        $display("--------------------------------------------");
        $finish;
    end

    // Independent safety guard for any unexpected stall.
    initial begin
        #10000;
        $fatal(1, "GLOBAL SIMULATION TIMEOUT");
    end

endmodule
