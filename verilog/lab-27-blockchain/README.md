# 🔬 Lab 27: Blockchain-Enabled Trust and Coordination in FPGA-Based Cyber-Physical Systems

## 🧩 1. Objective

This laboratory focuses on implementing **secure and decentralized coordination** among FPGA-based Cyber-Physical System (CPS) agents using blockchain principles.  
Students will:  

- Establish **peer-to-peer trust** among distributed FPGA nodes.  
- Record local actions, rewards, and updates on an **immutable ledger**.  
- Implement **smart-contract-style verification** for FPGA reconfiguration.  
- Integrate **quantum-entropy keys** (from Lab 26) for enhanced cryptographic security.  

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource | Description |
|:----------------|:-------------|
| **2–4 FPGA Boards (Basys 3 / PYNQ-Z2 / Zybo Z7)** | Distributed edge agents |
| **Vivado / Vitis HLS** | Hardware synthesis and co-design |
| **Python + Flask / Node.js** | Blockchain network simulation |
| **MQTT / WebSocket** | Peer-to-peer communication layer |
| **SQLite / JSON Ledger** | Local blockchain storage |
| **Quantum Random Bit Generator (from Lab 26)** | Entropy source for secure key generation |

---

## 🧠 3. Background Theory

### 3.1 Blockchain for CPS

Blockchain provides a **trust foundation** for decentralized cyber-physical coordination:  

- **Integrity** → Immutable records of every FPGA transaction.  
- **Transparency** → Each FPGA validates and confirms others’ actions.  
- **Consensus** → Shared agreement before reconfiguration or system updates.  

### 3.2 FPGA Role in Blockchain Networks

Each FPGA node acts simultaneously as:  

- **Miner** → Verifies transaction blocks.  
- **Controller** → Executes validated and approved operations.  
- **Sensor Node** → Generates and signs state transactions.  

This decentralized model ensures **tamper-proof and auditable CPS control**.  

---

## ⚙️ 4. FPGA Verilog Modules

### 4.1 Hash Computation Unit (SHA-Like)
```verilog
module Simple_Hash (
  input  [31:0] data_in,
  output [31:0] hash_out
);
  assign hash_out = {data_in[15:0] ^ data_in[31:16], data_in[7:0], data_in[23:16]};
endmodule
```
Performs a simplified **hash transformation**, mimicking block hashing operations for low-resource FPGA designs.  

### 4.2 Transaction Verifier
```verilog
module Tx_Verifier (
  input clk, rst,
  input [31:0] tx_data, prev_hash,
  output reg valid
);
  wire [31:0] new_hash;
  Simple_Hash H(.data_in(tx_data), .hash_out(new_hash));
  always @(posedge clk or posedge rst)
    if (rst) valid <= 0;
    else valid <= (new_hash[7:0] != prev_hash[7:0]);
endmodule
```
Verifies each transaction’s integrity by comparing new hash values with the previous block hash.  

### 4.3 Consensus Node Controller
```verilog
module Consensus_Node (
  input clk, rst,
  input [31:0] tx_data,
  output reg approved
);
  reg [3:0] vote_count;
  always @(posedge clk or posedge rst)
    if (rst) begin
      vote_count <= 0;
      approved <= 0;
    end else begin
      if (tx_data[0]) vote_count <= vote_count + 1;
      if (vote_count >= 3) approved <= 1; // quorum reached
    end
endmodule
```
Implements a simple **voting mechanism**—once three nodes agree, a control action is approved.  

### 4.4 Top-Level Blockchain-FPGA Agent
```verilog
module Blockchain_Agent (
  input clk, rst,
  input [31:0] sensor_tx,
  output [31:0] hash_out,
  output reg approved_action
);
  wire valid;
  Tx_Verifier verify(.clk(clk), .rst(rst), .tx_data(sensor_tx), .prev_hash(32'hABCD1234), .valid(valid));
  Consensus_Node node(.clk(clk), .rst(rst), .tx_data(sensor_tx), .approved(approved_action));
  Simple_Hash h(.data_in(sensor_tx), .hash_out(hash_out));
endmodule
```
Combines **verification**, **hashing**, and **consensus logic** into a single trusted FPGA node agent.  

---

## ☁️ 5. Python Blockchain Network Simulation
```python
import json, hashlib, time
from flask import Flask, request, jsonify
app = Flask(__name__)

chain = [{"index": 0, "timestamp": time.time(), "data": "Genesis", "prev_hash": "0"}]

@app.route("/add", methods=["POST"])
def add_block():
    data = request.json["data"]
    prev_hash = hashlib.sha256(json.dumps(chain[-1]).encode()).hexdigest()
    block = {"index": len(chain), "timestamp": time.time(), "data": data, "prev_hash": prev_hash}
    chain.append(block)
    return jsonify(block)

@app.route("/chain", methods=["GET"])
def get_chain():
    return jsonify(chain)

app.run(host="0.0.0.0", port=5002)
```
This Flask-based API simulates a **distributed blockchain ledger**, allowing FPGA nodes to post verified transactions.  

---

## 🧩 6. Experiment Procedure

1. Program each FPGA board with the `Blockchain_Agent` design.  
2. Launch the Python Flask blockchain server.  
3. Each FPGA node sends its **transaction** (e.g., temperature reading or control state).  
4. Observe **hash updates** and **consensus events** on the chain.  
5. Validate blockchain synchronization across all nodes.  
6. Compare with **digital-twin synchronization** (from Lab 25).  

---

## 📊 7. Observation Table

| Block | Timestamp | Data | Prev Hash | Valid | Consensus | Action |
|:--------|:--------------|:-------------|:-------------|:-------------|:-------------|:-------------|
| 0 | t₀ | Genesis | 0000… | – | – | Init |
| 1 | t₁ | Temp = 28 | A1B2… | ✓ | Yes | Recorded |
| 2 | t₂ | Temp = 29 | B3C4… | ✓ | Yes | Approved |
| 3 | t₃ | Alert = Overheat | C4D5… | ✓ | Yes | Triggered |

---

## 💡 8. Discussion Points

- How does blockchain ensure **trust and traceability** in CPS networks?  
- What **latency overhead** occurs during distributed validation?  
- How can **quantum entropy** from Lab 26 enhance blockchain key security?  
- Compare **blockchain-based CPS** vs. **centralized control architectures**.  

---

## 🧠 9. Post-Lab Exercises

- Integrate **digital twin data (Lab 25)** into blockchain transactions.  
- Use **quantum random keys** (Lab 26) as seeds for block hashes.  
- Implement **smart-contract-style** actuation using HLS or Python logic.  
- Build a **Node-RED dashboard** visualizing blockchain updates in real time.  
- Simulate **attack scenarios** and evaluate system resilience.  

---

## 🧾 10. Outcome

Students will be able to:  

- Design **secure FPGA coordination** using blockchain technology.  
- Implement **distributed consensus and verification** in hardware.  
- Integrate blockchain with **digital twin and quantum-assisted systems**.  
- Understand **CPS 8.0 architectures**—autonomous, decentralized, and trust-driven systems.  

---

## 📘 11. References

- Yaga et al., *NIST Blockchain Technology Overview*, 2018.  
- Mittal, S., *Secure FPGA Architectures for Distributed Edge Computing*, IEEE Access, 2024.  
- Xilinx, *UG908 – Dynamic Partial Reconfiguration Guide*.  
- Lee & Seshia, *Embedded Systems: A Cyber-Physical Systems Approach*.  
- Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*.  

---

✅ **Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** 1st Edition (2025)  
**License:** CC BY-NC 4.0  
