// Topic 14: simple 2-3-2 threshold ANN for traffic-level classification.
// Fixed example weights/thresholds; inference only (no training).
// road_a and road_b: unsigned 4-bit traffic levels (0..15).
// Outputs: traffic_class 00=Low, 01=Medium, 10=High;
//          green_time is a selected duration in seconds, NOT a countdown.
module smart_traffic_ai_top (
    input  wire [3:0] road_a,
    input  wire [3:0] road_b,
    output reg  [1:0] traffic_class,
    output reg  [5:0] green_time
);
    wire [4:0] total = {1'b0, road_a} + {1'b0, road_b};

    // Three illustrative hidden neurons, with step activation z > 0:
    wire h1 = (total >= 5'd5);  // step(total - 4)
    wire h2 = (total >= 5'd9);  // step(total - 8)
    wire h3 = (total >= 5'd13); // step(total - 12)

    always @(*) begin
        // Output layer (priority classification)
        if (h2 || h3)
            traffic_class = 2'b10; // High
        else if (h1)
            traffic_class = 2'b01; // Medium
        else
            traffic_class = 2'b00; // Low

        // Green-time selection (not a physical traffic-light timer)
        case (traffic_class)
            2'b00: green_time = 6'd10;
            2'b01: green_time = 6'd20;
            2'b10: green_time = 6'd30;
            default: green_time = 6'd10;
        endcase
    end
endmodule
