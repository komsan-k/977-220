`timescale 1ns / 1ps
// Simple self-checking testbench: 5 teaching examples + 6 boundaries.
module tb_smart_traffic_ai;
    reg  [3:0] road_a, road_b;
    wire [1:0] traffic_class;
    wire [5:0] green_time;
    integer passed, failed;

    smart_traffic_ai_top dut (
        .road_a(road_a),
        .road_b(road_b),
        .traffic_class(traffic_class),
        .green_time(green_time)
    );

    task check;
        input [3:0] a, b;
        input [1:0] expected_class;
        input [5:0] expected_time;
        begin
            road_a = a;
            road_b = b;
            #10;
            if ((traffic_class === expected_class) &&
                (green_time === expected_time)) begin
                passed = passed + 1;
                $display("PASS A=%0d B=%0d class=%b green=%0d s",
                         a, b, traffic_class, green_time);
            end else begin
                failed = failed + 1;
                $display("FAIL A=%0d B=%0d got=(%b,%0d) expected=(%b,%0d)",
                         a, b, traffic_class, green_time,
                         expected_class, expected_time);
            end
        end
    endtask

    initial begin
        road_a = 0; road_b = 0;
        passed = 0; failed = 0;

        // Five cases from the teaching lab
        check(4'd1, 4'd1, 2'b00, 6'd10);
        check(4'd3, 4'd3, 2'b01, 6'd20);
        check(4'd5, 4'd5, 2'b10, 6'd30);
        check(4'd7, 4'd7, 2'b10, 6'd30);
        check(4'd2, 4'd8, 2'b10, 6'd30);

        // Threshold boundaries: total = 4, 5, 8, 9, 12, 13
        check(4'd2, 4'd2, 2'b00, 6'd10);
        check(4'd2, 4'd3, 2'b01, 6'd20);
        check(4'd4, 4'd4, 2'b01, 6'd20);
        check(4'd4, 4'd5, 2'b10, 6'd30);
        check(4'd6, 4'd6, 2'b10, 6'd30);
        check(4'd6, 4'd7, 2'b10, 6'd30);

        $display("RESULT: %0d passed, %0d failed", passed, failed);
        if (failed == 0)
            $display("ALL 11 TESTS PASSED");
        else
            $display("TESTBENCH FAILED");
        $finish;
    end
endmodule
