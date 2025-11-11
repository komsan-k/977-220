// xor_ann.v
// Two-layer ANN solving XOR with step activations and fixed weights.
// Hidden layer: H1 = OR(A,B)  -> weights [1,1], bias -0.5
//                H2 = AND(A,B) -> weights [1,1], bias -1.5
// Output:       Y  = step( 1*H1 + (-2)*H2 - 0.5 )
module xor_ann(
    input  logic A,
    input  logic B,
    output logic Y,
    output logic H1,
    output logic H2
);
    // Q4.4 scale = 16
    // H1 = OR approx: A + B - 0.5
    neuron #(.W1(16'sd16), .W2(16'sd16), .B(-16'sd8)) u_h1 (.x1(A), .x2(B), .y(H1));
    // H2 = AND approx: A + B - 1.5
    neuron #(.W1(16'sd16), .W2(16'sd16), .B(-16'sd24)) u_h2 (.x1(A), .x2(B), .y(H2));

    // Output neuron uses hidden boolean outputs as inputs
    // Convert boolean to "neuron" inputs via x1/x2
    // Weights: +1 and -2 ; bias -0.5
    neuron #(.W1(16'sd16), .W2(-16'sd32), .B(-16'sd8)) u_out (.x1(H1), .x2(H2), .y(Y));
endmodule
