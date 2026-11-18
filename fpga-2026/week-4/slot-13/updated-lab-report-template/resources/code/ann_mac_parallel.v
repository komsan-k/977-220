// 2-2-1 ANN: two parallel MACs for hidden layer; MAC1 reused for output.
// Layer-parallel, not six simultaneous multipliers. 8 clocks per inference.
module ann_mac_parallel (
    input wire clk, rst, start, A, B,
    output reg H1, H2, Y,
    output reg busy, done
);
    `include "ann_weights.vh"
    localparam [3:0] IDLE=0, H_INIT=1, H_A=2, H_B=3, H_SAVE=4,
                     Y_INIT=5, Y_H1=6, Y_H2=7, Y_SAVE=8;
    reg [3:0] state;
    reg a_hold, b_hold;
    reg clear1, enable1, x1, clear2, enable2, x2;
    reg signed [15:0] bias1, bias2;
    reg signed [7:0] weight1, weight2;
    wire signed [15:0] acc1, acc2;

    mac_accum mac1(.clk(clk),.rst(rst),.clear(clear1),.enable(enable1),
                   .bias(bias1),.weight(weight1),.x(x1),.acc(acc1));
    mac_accum mac2(.clk(clk),.rst(rst),.clear(clear2),.enable(enable2),
                   .bias(bias2),.weight(weight2),.x(x2),.acc(acc2));

    always @(*) begin
        clear1=0; enable1=0; x1=0; bias1=16'sd0; weight1=8'sd0;
        clear2=0; enable2=0; x2=0; bias2=16'sd0; weight2=8'sd0;
        case (state)
            H_INIT: begin clear1=1; bias1=B1; clear2=1; bias2=B2; end
            H_A: begin
                enable1=1; weight1=W11; x1=a_hold;
                enable2=1; weight2=W21; x2=a_hold;
            end
            H_B: begin
                enable1=1; weight1=W12; x1=b_hold;
                enable2=1; weight2=W22; x2=b_hold;
            end
            Y_INIT: begin clear1=1; bias1=BO; end
            Y_H1: begin enable1=1; weight1=WO1; x1=H1; end
            Y_H2: begin enable1=1; weight1=WO2; x1=H2; end
            default: ;
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            state<=IDLE; a_hold<=0; b_hold<=0;
            H1<=0; H2<=0; Y<=0; busy<=0; done<=0;
        end else begin
            done<=0;
            case (state)
                IDLE: if (start) begin
                    a_hold<=A; b_hold<=B; busy<=1; state<=H_INIT;
                end
                H_INIT: state<=H_A;
                H_A: state<=H_B;
                H_B: state<=H_SAVE;
                H_SAVE: begin H1<=(acc1>0); H2<=(acc2>0); state<=Y_INIT; end
                Y_INIT: state<=Y_H1;
                Y_H1: state<=Y_H2;
                Y_H2: state<=Y_SAVE;
                Y_SAVE: begin Y<=(acc1>0); busy<=0; done<=1; state<=IDLE; end
                default: state<=IDLE;
            endcase
        end
    end
endmodule
