// activation_step.v
// Step activation: y = 1 if (x > 0) else 0
// x is signed fixed-point (Qm.n), compare to zero.
module activation_step #(
    parameter WIDTH = 16  // signed data width
)(
    input  signed [WIDTH-1:0] x,
    output        y
);
    assign y = (x > 0) ? 1'b1 : 1'b0;
endmodule
