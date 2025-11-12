// Welcome to JDoodle!
//
// You can execute code here in 88 languages. Right now you’re in the Verilog IDE. 
//
//  1. Click the orange Execute button ️▶ to execute the sample code below and see how it works.
//  2. Want help writing or debugging code? Type a query into JDroid on the right hand side ---------------->
//  3. Try the menu buttons on the left. Save your file, share code with friends and open saved projects.
//
// Want to change languages? Try the search bar up the top.

// 4-bit Multiplier using Structural Design
module multiplier_4bit (
    input  [3:0] A, B,
    output [7:0] P
);
    wire [3:0] pp0, pp1, pp2, pp3;

    // Partial products
    assign pp0 = A & {4{B[0]}};
    assign pp1 = A & {4{B[1]}};
    assign pp2 = A & {4{B[2]}};
    assign pp3 = A & {4{B[3]}};

    // Add partial products (shifted)
    assign P = (pp0) + (pp1 << 1) + (pp2 << 2) + (pp3 << 3);
endmodule

module tb_multiplier_4bit;
    reg [3:0] A, B;
    wire [7:0] P;

    multiplier_4bit uut (.A(A), .B(B), .P(P));

    initial begin
        $monitor("A=%d B=%d -> P=%d", A, B, P);
        A=4'd3;  B=4'd2;  #10;
        A=4'd5;  B=4'd9;  #10;
        A=4'd15; B=4'd15; #10;
        $finish;
    end
endmodule


