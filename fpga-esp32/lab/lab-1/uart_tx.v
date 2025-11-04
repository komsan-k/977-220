// uart_tx.v
module uart_tx (
    input  wire clk,
    input  wire baud_tick,
    input  wire start,
    input  wire [7:0] data,
    output reg  tx = 1'b1,
    output reg  busy = 1'b0
);
    reg [3:0] bitpos = 0;
    reg [9:0] shifter;
    always @(posedge clk) begin
        if (!busy && start) begin
            // start(0), 8 data LSB first, stop(1)
            shifter <= {1'b1, data, 1'b0};
            bitpos  <= 0;
            busy    <= 1'b1;
        end else if (busy && baud_tick) begin
            tx <= shifter[0];
            shifter <= {1'b1, shifter[9:1]};
            bitpos <= bitpos + 1;
            if (bitpos == 10) begin
                busy <= 1'b0;
                tx   <= 1'b1;
            end
        end
    end
endmodule
