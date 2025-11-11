// tb_xor_ann.v
`timescale 1ns/1ps
module tb_xor_ann;
    reg A, B;
    wire Y, H1, H2;

    xor_ann dut(.A(A), .B(B), .Y(Y), .H1(H1), .H2(H2));

    initial begin
        $display("A B | H1 H2 | Y");
        A=0; B=0; #1; $display("%0d %0d |  %0d  %0d | %0d", A,B,H1,H2,Y);
        A=0; B=1; #1; $display("%0d %0d |  %0d  %0d | %0d", A,B,H1,H2,Y);
        A=1; B=0; #1; $display("%0d %0d |  %0d  %0d | %0d", A,B,H1,H2,Y);
        A=1; B=1; #1; $display("%0d %0d |  %0d  %0d | %0d", A,B,H1,H2,Y);
        $finish;
    end
endmodule
