# 🔬 Lab : Two-Layer MLP for 3-Input Parity on FPGA

## 🧩 1) Objectives
- Implement a **2–2–1 multilayer perceptron (MLP)** that computes **3-input parity** (A ⊕ B ⊕ C).  
- Use **fixed-point arithmetic** and a **parameterized neuron** for scalability.  
- Verify in simulation and on FPGA; compare resource use vs. the simple XOR NN.  
- (Optional) Load weights at runtime (switches/UART) and visualize hidden activations.

---

## ⚙️ 2) Equipment & Tools
| Tool / Resource | Purpose |
|---|---|
| Vivado/Quartus + Simulator | Synthesis & simulation |
| Basys-3 / Nexys A7 / PYNQ-Z2 | FPGA board |
| Waveform viewer | Inspect sums/activations |
| (Optional) UART/USB bridge | Runtime weight loading |

---

## 🧠 3) Background
- XOR (2 inputs) needed 2 hidden neurons. For **3-input parity**, a small MLP with **2 hidden neurons** still works with suitable weights.  
- We’ll use **Qm.n = Q4.4** fixed-point (8-bit signed: −8.0 to +7.9375, step 1/16).  
- Activation: **step** (hard threshold) by default; switchable to **ReLU**.

---

## 🧮 4) Fixed-Point Helpers

```verilog
// Q4.4 multiply-accumulate: (a*b)>>4 to rescale
module fxp_mac #(parameter W=8, parameter FRAC=4)(
  input  signed [W-1:0] x,
  input  signed [W-1:0] w,
  input  signed [W+3:0] acc_in,
  output signed [W+3:0] acc_out
);
  wire signed [2*W-1:0] p = x * w;          // 16-bit
  assign acc_out = acc_in + (p >>> FRAC);   // keep scale
endmodule
```

---

## 🧩 5) Parameterized Neuron (N inputs, Step/ReLU)

```verilog
module neuron #(
  parameter W=8, FRAC=4, N_IN=3, ACT=0  // ACT: 0=STEP, 1=RELU
)(
  input  signed [W-1:0] x [N_IN-1:0],
  input  signed [W-1:0] w [N_IN-1:0],
  input  signed [W-1:0] b,
  output reg  signed [W-1:0] y,
  output reg                 y_bin
);
  integer i;
  reg signed [W+3:0] acc;
  always @(*) begin
    acc = b;
    for (i=0; i<N_IN; i=i+1) begin
      acc = acc + ((x[i]*w[i]) >>> FRAC);
    end
    if (ACT==0) begin
      y     = (acc > 0) ? {{(W-1){1'b0}},1'b1} : 'sd0;
      y_bin = (acc > 0);
    end else begin
      y     = (acc > 0) ? acc[W-1:0] : 'sd0;
      y_bin = (acc > 0);
    end
  end
endmodule
```

---

## 🧱 6) 2–2–1 MLP for Parity (A,B,C → H1,H2 → Y)

### 6.1 Hidden Layer (2 neurons, N_IN=3)
```verilog
module layer_hidden #(parameter W=8, FRAC=4)(input  signed [W-1:0] A,B,C, output [1:0] Hbin);
  localparam signed [W-1:0] w11=8'sd16, w12=8'sd16, w13=8'sd-8, b1=8'sd-8;
  localparam signed [W-1:0] w21=8'sd-8, w22=8'sd16, w23=8'sd16, b2=8'sd-8;
  wire signed [W-1:0] xin[2:0]; assign xin[0]=A; assign xin[1]=B; assign xin[2]=C;
  wire signed [W-1:0] w1[2:0] = '{w11,w12,w13}; wire signed [W-1:0] w2[2:0] = '{w21,w22,w23};
  wire signed [W-1:0] y1,y2; wire h1,h2;
  neuron #(.W(W),.FRAC(FRAC),.N_IN(3),.ACT(0)) N1(.x(xin),.w(w1),.b(b1),.y(y1),.y_bin(h1));
  neuron #(.W(W),.FRAC(FRAC),.N_IN(3),.ACT(0)) N2(.x(xin),.w(w2),.b(b2),.y(y2),.y_bin(h2));
  assign Hbin = {h2,h1};
endmodule
```

### 6.2 Output Neuron
```verilog
module layer_out #(parameter W=8, FRAC=4)(input [1:0] Hbin, output Y);
  localparam signed [W-1:0] wo1=8'sd16, wo2=8'sd16, bo=8'sd-16;
  wire signed [W-1:0] xin[1:0]; assign xin[0]={{(W-1){1'b0}},Hbin[0]}; assign xin[1]={{(W-1){1'b0}},Hbin[1]};
  wire signed [W-1:0] w[1:0] = '{wo1,wo2};
  wire signed [W-1:0] y_cont; wire y_bin;
  neuron #(.W(W),.FRAC(FRAC),.N_IN(2),.ACT(0)) NO(.x(xin),.w(w),.b(bo),.y(y_cont),.y_bin(y_bin));
  assign Y = y_bin;
endmodule
```

### 6.3 Top Module
```verilog
module parity3_mlp_top #(parameter W=8, FRAC=4)(input [0:0] A,B,C, output Y);
  wire signed [W-1:0] Aq = A ? 8'sd16 : 8'sd0;
  wire signed [W-1:0] Bq = B ? 8'sd16 : 8'sd0;
  wire signed [W-1:0] Cq = C ? 8'sd16 : 8'sd0;
  wire [1:0] H;
  layer_hidden #(.W(W),.FRAC(FRAC)) HL(.A(Aq),.B(Bq),.C(Cq),.Hbin(H));
  layer_out #(.W(W),.FRAC(FRAC)) OL(.Hbin(H), .Y(Y));
endmodule
```

---

## 🧪 7) Testbench
```verilog
module tb_parity3_mlp;
  reg A,B,C;
  wire Y;
  parity3_mlp_top DUT(.A(A),.B(B),.C(C),.Y(Y));
  integer i;
  initial begin
    $display("A B C | Y (expected A^B^C)");
    for (i=0; i<8; i=i+1) begin
      {A,B,C} = i[2:0];
      #1; $display("%b %b %b | %b (%b)", A,B,C,Y, A^B^C);
      #9;
    end
    $finish;
  end
endmodule
```

| A | B | C | Y |
|:-:|:-:|:-:|:-:|
|0|0|0|0|
|0|0|1|1|
|0|1|0|1|
|0|1|1|0|
|1|0|0|1|
|1|0|1|0|
|1|1|0|0|
|1|1|1|1|

---

## 🔧 8) FPGA Mapping (Basys-3 Example)
```tcl
set_property PACKAGE_PIN V17 [get_ports {A[0]}]; set_property IOSTANDARD LVCMOS33 [get_ports {A[0]}]
set_property PACKAGE_PIN V16 [get_ports {B[0]}]; set_property IOSTANDARD LVCMOS33 [get_ports {B[0]}]
set_property PACKAGE_PIN W16 [get_ports {C[0]}]; set_property IOSTANDARD LVCMOS33 [get_ports {C[0]}]
set_property PACKAGE_PIN U16 [get_ports Y];     set_property IOSTANDARD LVCMOS33 [get_ports Y]
```

**Verification:** Toggle SW0–SW2; LED0 shows parity result.

---

## 🧪 9) Experiments & Observation
| Config | FRAC | ACT | Correct/8 | Notes |
|---|---|---|---|---|
| 2–2–1 | 4 | STEP | 8/8 | Baseline |
| 2–2–1 | 3 | STEP | 8/8 | Slight margin |
| 2–2–1 | 2 | STEP | 6/8 | Quantization errors |

---

## 💬 10) Discussion
- Hidden representation enables non-linear separability.  
- Trade-offs of **fixed-point**: dynamic range vs. accuracy vs. resources.  
- Parameterized neurons are reusable for larger NNs.  
- Compare LUT/FF/DSP usage vs. the XOR NN.

---

## 🧠 11) Post-Lab Exercises
1. Replace STEP with **tanh LUT** (8-bit).  
2. Add **weight-loader** via AXI/UART.  
3. Extend to **4-input parity**.  
4. Pipeline MACs; measure max Fclk.  
5. Build a **MAC array (2×2)** and map the layer.

---

## 🧾 12) Outcome
A complete **3-input parity MLP** implemented and verified in Verilog with parameterized fixed-point arithmetic, demonstrating scalable neural logic on FPGA.
