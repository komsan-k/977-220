// baudgen_115200_from_100m.v
// Generates 1x baud tick: 100e6 / 115200 ≈ 868.055 -> use 868
module baudgen_115200_from_100m (
    input  wire clk,
    output reg  tick
);
    localparam DIVISOR = 868;
    reg [15:0] cnt = 0;
    always @(posedge clk) begin
        if (cnt == DIVISOR-1) begin
            cnt  <= 0;
            tick <= 1'b1;
        end else begin
            cnt  <= cnt + 1;
            tick <= 1'b0;
        end
    end
endmodule
