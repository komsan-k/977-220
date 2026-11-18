// Change PARALLEL in Vivado top-module parameter overrides before synthesis:
// PARALLEL=0 -> sequential 1 MAC; PARALLEL=1 -> layer-parallel 2 MACs.
// Do NOT instantiate both architectures for resource-comparison synthesis.
module ann_fpga_top #(parameter PARALLEL=0) (
    input wire clk, rst, start_button, A, B,
    output wire H1, H2, Y, busy
);
    reg start_ff1, start_ff2, start_prev;
    always @(posedge clk) begin
        if (rst) begin
            start_ff1<=0; start_ff2<=0; start_prev<=0;
        end else begin
            start_ff1<=start_button;
            start_ff2<=start_ff1;
            start_prev<=start_ff2;
        end
    end
    wire start_pulse = start_ff2 & ~start_prev;
    wire done_unused;
    generate if (PARALLEL == 0) begin: g_seq
        ann_mac_seq core(.clk(clk),.rst(rst),.start(start_pulse),.A(A),.B(B),
                         .H1(H1),.H2(H2),.Y(Y),.busy(busy),.done(done_unused));
    end else begin: g_par
        ann_mac_parallel core(.clk(clk),.rst(rst),.start(start_pulse),.A(A),.B(B),
                              .H1(H1),.H2(H2),.Y(Y),.busy(busy),.done(done_unused));
    end endgenerate
endmodule
