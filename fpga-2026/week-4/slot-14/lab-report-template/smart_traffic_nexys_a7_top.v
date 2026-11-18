// Nexys A7: SW[3:0] = Road A, SW[7:4] = Road B.
// LD[1:0] = traffic class, LD[7:2] = green time in 6-bit binary.
// This demonstration is combinational; no clock or reset is required.
module smart_traffic_nexys_a7_top (
    input  wire [7:0] sw,
    output wire [7:0] led
);
    wire [1:0] traffic_class;
    wire [5:0] green_time;

    smart_traffic_ai_top dut (
        .road_a(sw[3:0]),
        .road_b(sw[7:4]),
        .traffic_class(traffic_class),
        .green_time(green_time)
    );

    assign led = {green_time, traffic_class};
endmodule
