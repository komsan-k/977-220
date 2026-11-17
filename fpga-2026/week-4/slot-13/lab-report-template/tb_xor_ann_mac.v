`timescale 1ns / 1ps
module tb_xor_ann_mac;
    reg clk = 1'b0;
    always #5 clk = ~clk; // 100 MHz
    reg rst = 1'b1;
    reg start = 1'b0;
    reg A = 1'b0, B = 1'b0;
    wire H1, H2, Y, done, busy;
    integer errors = 0;

    xor_ann_mac_core dut (
        .clk(clk), .rst(rst), .start(start), .A(A), .B(B),
        .H1(H1), .H2(H2), .Y(Y), .done(done), .busy(busy)
    );

    task run_case;
        input a_in, b_in;
        reg expected;
        integer cycles;
        begin
            expected = a_in ^ b_in;
            @(negedge clk);
            A = a_in;
            B = b_in;
            start = 1'b1;
            repeat (4) @(negedge clk); // long enough for synchronizer
            start = 1'b0;

            cycles = 0;
            while ((done !== 1'b1) && (cycles < 40)) begin
                @(negedge clk);
                cycles = cycles + 1;
            end
            if (done !== 1'b1) begin
                $display("TIMEOUT A=%b B=%b", a_in, b_in);
                errors = errors + 1;
            end else if ((Y !== expected) ||
                         (H1 !== (a_in | b_in)) ||
                         (H2 !== ~(a_in & b_in))) begin
                $display("FAIL A=%b B=%b H1=%b H2=%b Y=%b expected=%b",
                         a_in, b_in, H1, H2, Y, expected);
                errors = errors + 1;
            end else begin
                $display("PASS A=%b B=%b H1=%b H2=%b Y=%b cycles=%0d",
                         a_in, b_in, H1, H2, Y, cycles);
            end
            repeat (3) @(negedge clk);
        end
    endtask

    initial begin
        repeat (3) @(negedge clk);
        rst = 1'b0;
        run_case(1'b0, 1'b0);
        run_case(1'b0, 1'b1);
        run_case(1'b1, 1'b0);
        run_case(1'b1, 1'b1);
        if (errors == 0)
            $display("ALL 4 XOR CASES PASSED");
        else
            $display("TOTAL FAILURES: %0d", errors);
        $finish;
    end
endmodule
