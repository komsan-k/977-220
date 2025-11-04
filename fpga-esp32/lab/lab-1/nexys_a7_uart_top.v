// nexys_a7_uart_top.v
module nexys_a7_uart_top (
    input  wire        clk_100mhz,     // 100 MHz system clock
    input  wire        uart_rx_i,      // from ESP32 TX
    output wire        uart_tx_o,      // to ESP32 RX
    input  wire [7:0]  sw,             // 8 board switches
    output reg  [7:0]  led             // 8 board LEDs
);

    // ===== Baud tick for 115200 from 100 MHz =====
    wire baud_tick;
    baudgen_115200_from_100m u_baud (
        .clk(clk_100mhz),
        .tick(baud_tick)
    );

    // ===== UART RX/TX =====
    wire        rx_ready;
    wire [7:0]  rx_data;
    uart_rx u_rx (
        .clk(clk_100mhz), .baud_tick(baud_tick),
        .rx(uart_rx_i),
        .data(rx_data), .data_ready(rx_ready)
    );

    reg         tx_start = 1'b0;
    reg  [7:0]  tx_data  = 8'h00;
    wire        tx_busy;
    uart_tx u_tx (
        .clk(clk_100mhz), .baud_tick(baud_tick),
        .start(tx_start), .data(tx_data),
        .tx(uart_tx_o), .busy(tx_busy)
    );

    // ===== Simple command parser =====
    localparam CMD_SET_LED   = 8'h55; // next byte is LED value
    localparam CMD_REQ_SW    = 8'hAA; // request switch value
    localparam RSP_SW_HDR    = 8'h53; // 'S'

    reg [1:0]  state = 0; // 0: idle, 1: waiting LED byte
    reg [7:0]  last_cmd;

    always @(posedge clk_100mhz) begin
        // default
        tx_start <= 1'b0;

        if (rx_ready) begin
            case (state)
                0: begin
                    last_cmd <= rx_data;
                    if (rx_data == CMD_SET_LED) begin
                        state <= 1;
                    end else if (rx_data == CMD_REQ_SW) begin
                        // send two bytes: 'S' then sw
                        if (!tx_busy) begin
                            tx_data  <= RSP_SW_HDR;
                            tx_start <= 1'b1;
                        end
                    end
                end
                1: begin
                    // LED payload
                    led   <= rx_data;
                    state <= 0;
                end
            endcase
        end

        // If we just sent 'S', queue switch byte after TX is free
        if (last_cmd == CMD_REQ_SW && !tx_busy && !tx_start) begin
            tx_data  <= sw;
            tx_start <= 1'b1;
            last_cmd <= 8'h00;
        end
    end
endmodule
