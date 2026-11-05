`timescale 1ns / 1ps

module led_blinker_tb;

    reg clk = 1'b0;
    wire led;

    led_blinker dut (.clk(clk), .led(led));

    always #5 clk = ~clk;  // 100 MHz clock

    initial begin
        #700_000_000;      // Simulate 700 ms
        $finish;
    end

endmodule
