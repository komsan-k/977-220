// uart_rx.v
module uart_rx (
    input  wire clk,
    input  wire baud_tick,
    input  wire rx,
    output reg  [7:0] data = 8'h00,
    output reg        data_ready = 1'b0
);
    reg [3:0] bitpos = 0;
    reg [7:0] dshift = 8'h00;
    reg       receiving = 1'b0;
    reg [1:0] sync = 2'b11;

    always @(posedge clk) sync <= {sync[0], rx};

    always @(posedge clk) begin
        data_ready <= 1'b0;

        if (!receiving) begin
            if (sync == 2'b10) begin
                receiving <= 1'b1;
                bitpos    <= 0;
            end
        end else if (baud_tick) begin
            bitpos <= bitpos + 1;
            case (bitpos)
                1,2,3,4,5,6,7,8: dshift <= {sync[1], dshift[7:1]};
                9: begin
                    data        <= dshift;
                    data_ready  <= 1'b1;
                    receiving   <= 1'b0;
                end
            endcase
        end
    end
endmodule
