`timescale 1ns / 1ps

module led_blinker_tb;

    reg clk = 0;
    wire led;

    led_blinker dut (.clk(clk), .led(led));

    always #5 clk = ~clk;

    initial begin
        // Start one count before the MSB changes to 1.
        @(negedge clk);
        dut.counter = 26'h1FFFFFF;

        // Let the LED turn on, then move to just before wraparound.
        repeat (2) @(negedge clk);
        dut.counter = 26'h3FFFFFF;

        // Let the LED turn off, then end the simulation.
        repeat (2) @(negedge clk);
        $finish;
    end

endmodule
