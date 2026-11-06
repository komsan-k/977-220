module counter4 (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    output reg  [3:0] count
);

    reg [25:0] counter;
    wire slow_tick;

    assign slow_tick = (counter == 26'd33_554_431);

    // Block 1: Clock divider
    always @(posedge clk) begin
        if (reset)
            counter <= 26'd0;
        else
            counter <= counter + 1'b1;
    end

    // Block 2: Four-bit counter
    always @(posedge clk) begin
        if (reset)
            count <= 4'd0;
        else if (enable && slow_tick)
            count <= count + 1'b1;
    end

endmodule
