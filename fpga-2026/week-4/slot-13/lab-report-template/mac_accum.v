// Signed 8x8 multiply-accumulate datapath, with a 16-bit accumulator.
module mac_accum (
    input  wire               clk,
    input  wire               rst,
    input  wire               load_bias,
    input  wire               mac_en,
    input  wire signed [7:0]  bias,
    input  wire signed [7:0]  x,
    input  wire signed [7:0]  w,
    output reg  signed [15:0] acc
);
    always @(posedge clk) begin
        if (rst)
            acc <= 16'sd0;
        else if (load_bias)
            acc <= {{8{bias[7]}}, bias};
        else if (mac_en)
            acc <= acc + (x * w);
    end
endmodule
