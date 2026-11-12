`timescale 1ns / 1ps

module tb_multiplier_4bit_structural;
    reg [3:0] A, B;
    wire [7:0] P;
    integer pass_count = 0;
    integer fail_count = 0;

    multiplier_4bit_structural DUT (
        .A(A), .B(B), .P(P)
    );

    task test;
        input [3:0] a_in, b_in;
        input [7:0] expected;
        begin
            A = a_in;
            B = b_in;
            #10;
            if (P === expected) begin
                $display("%2d  %2d  %3d  %8b  PASS", A, B, expected, P);
                pass_count = pass_count + 1;
            end else begin
                $display("%2d  %2d  %3d  %8b  FAIL", A, B, expected, P);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $display("A   B   Expected  LED[7:0]  Result");
        $display("---------------------------------");
        test(0, 15, 0);
        test(3, 2, 6);
        test(7, 5, 35);
        test(11, 5, 55);
        test(15, 15, 225);
        $display("---------------------------------");
        $display("PASS = %0d, FAIL = %0d", pass_count, fail_count);
        $finish;
    end
endmodule
