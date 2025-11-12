// or_ann.v
// Single neuron implementing logical OR
module or_ann(
    input  logic A,
    input  logic B,
    output logic Y
);
    // Parameters for weights and bias
    real W1 = 1.0, W2 = 1.0, BIAS = -0.5;
    real sum;

    always_comb begin
        sum = W1*A + W2*B + BIAS;
        Y = (sum > 0) ? 1'b1 : 1'b0;
    end
endmodule
