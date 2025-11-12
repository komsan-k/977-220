// tb_or_ann.v
module tb_or_ann;
    reg A, B;
    wire Y;

    or_ann uut (.A(A), .B(B), .Y(Y));

    initial begin
        $display("A B | Y");
        A=0; B=0; #1; $display("%b %b | %b", A,B,Y);
        A=0; B=1; #1; $display("%b %b | %b", A,B,Y);
        A=1; B=0; #1; $display("%b %b | %b", A,B,Y);
        A=1; B=1; #1; $display("%b %b | %b", A,B,Y);
        $finish;
    end
endmodule
