# 🔬 Lab 28: Decentralized Autonomous Cyber-Physical FPGA Network (DACPI) with Self-Governance

## 🧩 1. Objective

This laboratory introduces the design of a **Decentralized Autonomous Cyber-Physical FPGA Network (DACPI)** — a system in which multiple FPGA-based agents collaboratively make governance decisions using smart-contract logic.

Students will:
- Implement **voting and bidding mechanisms** directly in FPGA logic.
- Integrate a **smart-contract API** for rule-based decision execution.
- Demonstrate **self-regulation** (e.g., auto-load balancing and adaptive resource sharing).
- Visualize real-time governance events via a **digital-twin dashboard**.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource | Description |
|:----------------|:-------------|
| **3–5 FPGA boards (Basys 3 / PYNQ-Z2 / Zybo Z7)** | Autonomous distributed nodes |
| **Vivado / Vitis HLS** | FPGA synthesis and simulation |
| **Python + Flask / Node-RED / MQTT** | Smart contract logic and visualization |
| **SQLite / JSON ledger** | Distributed state logging |
| **Sensors & Actuators** | Temperature, light, or motor control |

---

## 🧠 3. Background Theory

### 3.1 Decentralized Autonomous System (DAS)

Each FPGA operates as a:
- **Producer** – generates data and provides services.
- **Consumer** – requests shared resources.
- **Validator** – verifies and approves system actions.

Smart contracts encode cooperative rules, such as:
> *“If power exceeds threshold, redistribute load among active nodes.”*

### 3.2 Consensus and Voting

Each node maintains a **reputation score (Ri)** based on reliability and feedback.
A collective decision is reached when:

∑ Ri × Vi ≥ θ

where:
- Vi = vote (1 = approve, 0 = reject)
- θ = decision threshold

This enables **trust-weighted governance** and **dynamic resource negotiation**.

---

## ⚙️ 4. Verilog Implementation

### 4.1 Reputation Register
```verilog
module Reputation (
  input clk, rst,
  input [7:0] feedback,
  output reg [15:0] rep_score
);
  always @(posedge clk or posedge rst)
    if (rst) rep_score <= 100;
    else rep_score <= rep_score + feedback - 1; // Decay and reward
endmodule
```

### 4.2 Voting Module
```verilog
module Vote_Node (
  input clk, rst,
  input [15:0] rep_score,
  input [7:0] proposal_id,
  output reg vote
);
  always @(posedge clk or posedge rst)
    if (rst) vote <= 0;
    else vote <= (rep_score > 80 && proposal_id[0]) ? 1 : 0;
endmodule
```

### 4.3 Resource Manager
```verilog
module Resource_Manager (
  input clk, rst,
  input [7:0] load,
  input approve,
  output reg [7:0] allocation
);
  always @(posedge clk or posedge rst)
    if (rst) allocation <= 50;
    else if (approve && load > 100) allocation <= allocation - 10;
    else if (!approve && load < 50) allocation <= allocation + 5;
endmodule
```

### 4.4 Top-Level DACPI Node
```verilog
module DACPI_Node (
  input clk, rst,
  input [7:0] load, proposal_id,
  input [7:0] feedback,
  output [7:0] allocation,
  output reg vote
);
  wire [15:0] rep;
  Reputation repu(.clk(clk), .rst(rst), .feedback(feedback), .rep_score(rep));
  Vote_Node voter(.clk(clk), .rst(rst), .rep_score(rep), .proposal_id(proposal_id), .vote(vote));
  Resource_Manager res(.clk(clk), .rst(rst), .load(load), .approve(vote), .allocation(allocation));
endmodule
```

---

## ☁️ 5. Smart-Contract Simulation (Python)
```python
from flask import Flask, request, jsonify
import json
app = Flask(__name__)
ledger = []

@app.route('/proposal', methods=['POST'])
def proposal():
    data = request.json
    decision = sum(v['vote']*v['rep'] for v in data['votes']) > 200
    contract = {'id': data['id'], 'decision': decision}
    ledger.append(contract)
    return jsonify(contract)

@app.route('/ledger')
def show():
    return jsonify(ledger)

app.run(host='0.0.0.0', port=5003)
```

---

## 🧮 6. Experiment Procedure

1. Configure 3–5 FPGA boards with the **DACPI_Node** design.
2. Publish each node’s **vote**, **reputation**, and **load** using MQTT.
3. Run the **Flask contract server** to process proposals.
4. Observe **automatic load redistribution** when proposals are approved.
5. Visualize decision flow in **Node-RED dashboard** or digital twin interface.

---

## 📊 7. Observation Table

| Cycle | Node 1 Load | Node 2 Load | Proposal ID | Votes (Y/N) | Decision | Allocation % | System State |
|:------|:-------------|:-------------|:-------------|:-------------|:-------------|:-------------|:-------------|
| 1 | 60 | 50 | 1 | 3/1 | Approved | 45/55 | Balanced |
| 3 | 110 | 40 | 2 | 4/0 | Approved | 35/65 | Rebalanced |
| 5 | 70 | 70 | 3 | 2/2 | Rejected | 50/50 | Stable |

---

## 💡 8. Discussion Points

- How does decentralized governance enhance **CPS resilience**?
- What are the limitations of on-FPGA voting latency compared to cloud orchestration?
- Could **reputation and consensus** be integrated with **blockchain (Lab 27)**?
- How might DACPI handle **adversarial or faulty nodes** autonomously?

---

## 🧠 9. Post-Lab Exercises

- Implement **multi-tier governance** (local → regional → global).
- Add **quantum entropy** (Lab 26) for proposal randomization.
- Introduce **smart contract revocation** and dynamic reconfiguration.
- Integrate with **digital twin (Lab 25)** visualization.
- Compare **centralized vs autonomous decision** efficiency.

---

## 🧾 10. Outcome

Students will be able to:

- Implement **hardware-embedded voting and governance**.
- Execute **smart contracts** within distributed FPGA nodes.
- Evaluate **autonomous coordination and policy evolution**.
- Understand **CPS 9.0** — *Decentralized Autonomous Cyber-Physical Intelligence*.

---

## 📘 11. References

- Buterin, V., *Ethereum Whitepaper* (2014).
- Mittal, S., *Secure and Governable FPGA Systems for Edge AI*, IEEE Access, 2025.
- NIST IR 8202 – *Blockchain for Cyber-Physical Integration*.
- Lee & Seshia, *Embedded Systems: A CPS Approach*.
- Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*.

---

✅ **Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** 1st Edition (2025)  
**License:** CC BY-NC 4.0  
