// nxor_ann.v
// Two-layer ANN implementing NXOR using step activations
module nxor_ann(
    input  logic A,
    input  logic B,
    output logic Y
);
    logic H1, H2;
    real W1 = 1.0, W2 = 1.0;
    real sum1, sum2, sum_out;

    // Hidden layer
    always_comb begin
        sum1 = W1*A + W2*B - 0.5;  // H1 = OR
        H1 = (sum1 > 0) ? 1 : 0;

        sum2 = W1*A + W2*B - 1.5;  // H2 = AND
        H2 = (sum2 > 0) ? 1 : 0;

        // Output neuron (invert XOR)
        sum_out = (-1*H1) + (2*H2) + 0.5;
        Y = (sum_out > 0) ? 1 : 0;
    end
endmodule
