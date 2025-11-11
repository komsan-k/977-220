// neuron.v
// Generic perceptron: sum = w1*x1 + w2*x2 + b (all fixed-point, same scale)
// Outputs step(sum)
module neuron #(
    parameter WIDTH = 16,
    parameter signed [WIDTH-1:0] W1 = 16'sd16,  // default 1.0 in Q4.4 (scale=16)
    parameter signed [WIDTH-1:0] W2 = 16'sd16,  // default 1.0
    parameter signed [WIDTH-1:0] B  = -16'sd8   // default -0.5
)(
    input  logic x1,     // boolean input 0/1
    input  logic x2,     // boolean input 0/1
    output logic y
);
    // scale boolean inputs up to fixed-point
    wire signed [WIDTH-1:0] x1_fx = x1 ? 16'sd16 : 16'sd0; // 1.0 -> 16
    wire signed [WIDTH-1:0] x2_fx = x2 ? 16'sd16 : 16'sd0;

    wire signed [WIDTH-1:0] s1 = (W1 * x1_fx) >>> 4; // downscale (Q4.4)
    wire signed [WIDTH-1:0] s2 = (W2 * x2_fx) >>> 4;
    wire signed [WIDTH-1:0] sum = s1 + s2 + B;

    activation_step #(.WIDTH(WIDTH)) act (.x(sum), .y(y));
endmodule
