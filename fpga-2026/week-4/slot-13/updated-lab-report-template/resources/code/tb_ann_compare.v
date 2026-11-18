`timescale 1ns/1ps
module tb_ann_compare;
    reg clk=0, rst=1, start=0, A=0, B=0;
    always #5 clk=~clk; // 100 MHz
    wire hs1,hs2,ys,bs,ds;
    wire hp1,hp2,yp,bp,dp;
    ann_mac_seq seq(.clk(clk),.rst(rst),.start(start),.A(A),.B(B),
        .H1(hs1),.H2(hs2),.Y(ys),.busy(bs),.done(ds));
    ann_mac_parallel par(.clk(clk),.rst(rst),.start(start),.A(A),.B(B),
        .H1(hp1),.H2(hp2),.Y(yp),.busy(bp),.done(dp));
    integer case_id, k, seq_latency, par_latency, expected;
    initial begin
        repeat(3) @(negedge clk);
        rst=0;
        for (case_id=0; case_id<4; case_id=case_id+1) begin
            @(negedge clk);
            A=case_id[1]; B=case_id[0]; expected=A^B;
            start=1;
            @(negedge clk);
            start=0;
            seq_latency=0; par_latency=0;
            for (k=1; k<=16; k=k+1) begin
                @(posedge clk); #1;
                if (ds) seq_latency=k;
                if (dp) par_latency=k;
            end
            if (seq_latency != 12 || par_latency != 8 ||
                ys !== expected[0] || yp !== expected[0] ||
                hs1 !== hp1 || hs2 !== hp2)
                $fatal(1, "FAIL A=%b B=%b seq=%b par=%b seq_cycles=%0d par_cycles=%0d",
                    A,B,ys,yp,seq_latency,par_latency);
            $display("PASS A=%b B=%b Y=%b seq=%0d cycles par=%0d cycles",
                A,B,ys,seq_latency,par_latency);
        end
        $display("ALL 4 XOR CASES PASS");
        $finish;
    end
endmodule
