// 2-2-1 ANN: one shared MAC, 12 clocks per inference after start accepted.
module ann_mac_seq (
    input wire clk, rst, start, A, B,
    output reg H1, H2, Y,
    output reg busy, done
);
    `include "ann_weights.vh"
    localparam [3:0] IDLE=0, H1_INIT=1, H1_A=2, H1_B=3, H1_SAVE=4,
                     H2_INIT=5, H2_A=6, H2_B=7, H2_SAVE=8,
                     Y_INIT=9, Y_H1=10, Y_H2=11, Y_SAVE=12;
    reg [3:0] state;
    reg a_hold, b_hold;
    reg clear, enable, x;
    reg signed [15:0] bias;
    reg signed [7:0] weight;
    wire signed [15:0] acc;

    mac_accum mac0(.clk(clk),.rst(rst),.clear(clear),.enable(enable),
                   .bias(bias),.weight(weight),.x(x),.acc(acc));

    always @(*) begin
        clear=0; enable=0; x=0; bias=16'sd0; weight=8'sd0;
        case (state)
            H1_INIT: begin clear=1; bias=B1; end
            H1_A:    begin enable=1; weight=W11; x=a_hold; end
            H1_B:    begin enable=1; weight=W12; x=b_hold; end
            H2_INIT: begin clear=1; bias=B2; end
            H2_A:    begin enable=1; weight=W21; x=a_hold; end
            H2_B:    begin enable=1; weight=W22; x=b_hold; end
            Y_INIT:  begin clear=1; bias=BO; end
            Y_H1:    begin enable=1; weight=WO1; x=H1; end
            Y_H2:    begin enable=1; weight=WO2; x=H2; end
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
                    a_hold<=A; b_hold<=B; busy<=1; state<=H1_INIT;
                end
                H1_INIT: state<=H1_A;
                H1_A: state<=H1_B;
                H1_B: state<=H1_SAVE;
                H1_SAVE: begin H1 <= (acc > 0); state<=H2_INIT; end
                H2_INIT: state<=H2_A;
                H2_A: state<=H2_B;
                H2_B: state<=H2_SAVE;
                H2_SAVE: begin H2 <= (acc > 0); state<=Y_INIT; end
                Y_INIT: state<=Y_H1;
                Y_H1: state<=Y_H2;
                Y_H2: state<=Y_SAVE;
                Y_SAVE: begin Y <= (acc > 0); busy<=0; done<=1; state<=IDLE; end
                default: state<=IDLE;
            endcase
        end
    end
endmodule
