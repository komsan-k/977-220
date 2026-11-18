// One signed multiply-accumulate datapath with bias initialization.
// x is binary; synthesis may optimize multiplication into a mux/adder.
module mac_accum (
    input wire clk, rst, clear, enable,
    input wire signed [15:0] bias,
    input wire signed [7:0] weight,
    input wire x,
    output reg signed [15:0] acc
);
    wire signed [1:0] x_signed = $signed({1'b0, x});
    wire signed [15:0] product = weight * x_signed;
    always @(posedge clk) begin
        if (rst) acc <= 16'sd0;
        else if (clear) acc <= bias;
        else if (enable) acc <= acc + product;
    end
endmodule
