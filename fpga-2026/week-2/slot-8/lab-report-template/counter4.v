module counter4 (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    output reg  [3:0] count
);

    reg [25:0] divider;

    always @(posedge clk) begin
        if (reset) begin
            divider <= 0;
            count   <= 0;
        end else begin
            divider <= divider + 1'b1;

            if (enable && (&divider))
                count <= count + 1'b1;
        end
    end

endmodule
