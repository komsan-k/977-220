`timescale 1ns / 1ps

// Exhaustive testbench for 4 x 4-bit unsigned multiplier
// DUT: multiplier_4bit_behavioral
// Tests all 16 x 16 = 256 operand combinations.

module tb_multiplier_4bit_exhaustive;

    reg  [3:0] A;
    reg  [3:0] B;
    wire [7:0] P;

    integer i;
    integer j;
    integer total_tests;
    integer pass_count;
    integer fail_count;
    reg [7:0] expected;

    multiplier_4bit_behavioral dut (
        .A(A),
        .B(B),
        .P(P)
    );

    initial begin
        A = 4'd0;
        B = 4'd0;
        total_tests = 0;
        pass_count = 0;
        fail_count = 0;

        $display("============================================");
        $display("4 x 4-bit Unsigned Multiplier: Exhaustive Test");
        $display("============================================");

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                A = i;
                B = j;
                expected = i * j;
                #10;  // Allow combinational logic to settle.

                total_tests = total_tests + 1;
                if (P === expected) begin
                    pass_count = pass_count + 1;
                end else begin
                    fail_count = fail_count + 1;
                    $display("FAIL: A=%0d B=%0d | expected=%0d (%08b), got=%0d (%08b)",
                             A, B, expected, expected, P, P);
                end
            end
        end

        $display("--------------------------------------------");
        $display("Total tests : %0d", total_tests);
        $display("Passed      : %0d", pass_count);
        $display("Failed      : %0d", fail_count);
        if (fail_count == 0 && total_tests == 256)
            $display("FINAL RESULT: PASS - All 256 cases matched.");
        else
            $display("FINAL RESULT: FAIL - Review mismatches.");
        $display("============================================");
        $finish;
    end

endmodule
