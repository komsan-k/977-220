# Introduction to AI on FPGA

This four-topic sequence introduces neural-network implementation on FPGAs, progressing from a simple XOR network to traffic-control applications, binary neural networks, and convolutional neural networks.

## Topic 13: AI-FPGA — Artificial Neural Network for XOR Function

Explore how a small artificial neural network (ANN) learns the nonlinear XOR function and implements inference in digital hardware.

- Neurons, weights, biases, and activation functions.
- Training a multilayer network for XOR.
- Converting trained parameters to fixed-point representation.
- Implementing and simulating FPGA inference.

**Practice:** Train an XOR network, implement it in Verilog/SystemVerilog, and verify all four input combinations.

## Topic 14: AI-FPGA — ANN for Smart Traffic Control

Apply an ANN to traffic-demand estimation and integrate its predictions with an FPGA traffic-light controller.

- Representing traffic inputs, such as vehicle counts and queue lengths.
- Preparing training data and defining prediction targets.
- Implementing fixed-point ANN inference.
- Combining ANN recommendations with an FSM that enforces valid signal sequences and timing limits.

**Practice:** Use simulated traffic inputs to select bounded green-light durations and compare the results with fixed-time control.

## Topic 15: AI-FPGA — Binary Neural Network (BNN)

Investigate neural networks that use binary weights and activations to simplify FPGA inference.

- Binary representations and activation thresholds.
- XNOR and population-count operations.
- Mapping trained parameters to hardware.
- Comparing prediction accuracy, resource utilization, and latency with a fixed-point ANN.

**Practice:** Implement a small BNN classifier and verify its hardware outputs against a software reference.

## Topic 16: AI-FPGA — Convolutional Neural Network (CNN)

Introduce FPGA architectures for extracting image features and performing CNN inference.

- Convolution, activation, pooling, and classification.
- Fixed-point arithmetic and parameter storage.
- Sliding windows, line buffers, and pipelined processing.
- Comparing hardware outputs with software predictions.

**Practice:** Implement a small convolution layer for grayscale images, verify its numerical output, and extend it toward a compact image classifier.

