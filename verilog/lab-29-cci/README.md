# 🔬 Lab 29: FPGA Collective Cognitive Intelligence (CCI) Network for Goal-Oriented CPS

## 🧩 1. Objective

Students will design a collective FPGA swarm that collaborates using knowledge graphs and reinforcement sharing.

They will:
- Implement local cognition modules on FPGA.
- Create shared knowledge synchronization through a distributed memory layer.
- Use goal propagation to coordinate actions among agents.
- Demonstrate emergent collective behavior for adaptive CPS environments.

---

## ⚙️ 2. Equipment and Tools

| Tool / Resource | Description |
|:----------------|:-------------|
| **3–6 FPGA boards (Basys 3 / PYNQ-Z2 / Zybo Z7)** | Collective hardware agents |
| **Vivado / Vitis HLS** | FPGA synthesis and simulation |
| **Python + Neo4j / Node-RED** | Knowledge graph & orchestration |
| **MQTT / WebSocket** | Inter-agent communication |
| **Sensors (Temp, LDR, IMU)** | Environment perception |
| **Actuators (Servo, LED)** | Collective action output |

---

## 🧠 3. Background Theory

### 3.1 Cognitive Collective Intelligence

Each FPGA agent performs:
- **Sense → Process → Learn → Share abstracted knowledge**
- Uses **goal feedback** instead of direct control commands.
- Updates a **Cognitive State Graph (CSG)** representing the group’s evolving state and reasoning.

### 3.2 Reinforcement Sharing Model

Agents share and merge learned policy weights according to:

\[ Q_{shared}(s,a) = (1 - α)Q_{shared}(s,a) + αQ_i(s,a) \]

This enables **collective learning** across distributed, heterogeneous agents.

---

## ⚙️ 4. Verilog Implementation

### 4.1 Cognitive State Encoder
```verilog
module State_Encoder (
  input clk, rst,
  input [11:0] sensor_data,
  output reg [7:0] state
);
  always @(posedge clk or posedge rst)
    if (rst) state <= 0;
    else state <= sensor_data[11:4];  // Compress to symbolic representation
endmodule
```

### 4.2 Local Q-Updater
```verilog
module Q_Update_Local (
  input clk, rst,
  input [7:0] state, action,
  input [15:0] reward,
  output reg [15:0] q_value
);
  parameter ALPHA = 2;
  always @(posedge clk or posedge rst)
    if (rst) q_value <= 0;
    else q_value <= q_value + ((reward - q_value) / ALPHA);
endmodule
```

### 4.3 Shared Knowledge Interface
```verilog
module Knowledge_Sync (
  input clk, rst,
  input [15:0] q_local,
  input [15:0] q_shared_in,
  output reg [15:0] q_shared_out
);
  parameter BETA = 3;
  always @(posedge clk or posedge rst)
    if (rst) q_shared_out <= 0;
    else q_shared_out <= q_shared_in + ((q_local - q_shared_in) / BETA);
endmodule
```

### 4.4 Goal Propagation Controller
```verilog
module Goal_Controller (
  input clk, rst,
  input [7:0] goal_state,
  input [7:0] current_state,
  output reg [7:0] delta_action
);
  always @(posedge clk or posedge rst)
    if (rst) delta_action <= 0;
    else delta_action <= (goal_state > current_state) ?
                         (goal_state - current_state) >> 1 :
                         (current_state - goal_state) >> 1;
endmodule
```

### 4.5 Top-Level CCI Node
```verilog
module CCI_Node (
  input clk, rst,
  input [11:0] sensor,
  input [7:0] goal_state,
  input [15:0] shared_q_in,
  output [7:0] action_out,
  output [15:0] shared_q_out
);
  wire [7:0] state;
  wire [15:0] q_local, q_sync;
  wire [7:0] action;

  State_Encoder enc(.clk(clk), .rst(rst), .sensor_data(sensor), .state(state));
  Q_Update_Local ql(.clk(clk), .rst(rst), .state(state), .action(action),
                    .reward(100 - state), .q_value(q_local));
  Knowledge_Sync ks(.clk(clk), .rst(rst), .q_local(q_local),
                    .q_shared_in(shared_q_in), .q_shared_out(shared_q_out));
  Goal_Controller gc(.clk(clk), .rst(rst), .goal_state(goal_state),
                     .current_state(state), .delta_action(action));

  assign action_out = action;
endmodule
```

---

## ☁️ 5. Knowledge Graph Orchestration (Python + Neo4j)
```python
from py2neo import Graph, Node, Relationship
import random, time

graph = Graph("bolt://localhost:7687", auth=("neo4j", "password"))

def update_graph(node_id, state, reward):
    n = Node("Agent", id=node_id, state=state, reward=reward)
    graph.merge(n, "Agent", "id")
    rel = Relationship(n, "SHARED_WITH", n)
    graph.merge(rel)
    print(f"[{node_id}] Updated state={state}, reward={reward}")

for cycle in range(10):
    for node in range(3):
        state = random.randint(0, 255)
        reward = 255 - state
        update_graph(node, state, reward)
        time.sleep(1)
```

---

## 🧮 6. Experiment Procedure

1. Deploy **CCI_Node** on multiple FPGA boards.  
2. Connect all nodes using **UART or MQTT** for Q-value exchange.  
3. Define a global **goal state** (e.g., temperature = 128).  
4. Run the **Neo4j knowledge graph** to visualize evolving agent cognition.  
5. Observe **goal convergence** and emergent coordination patterns.  

---

## 📊 7. Observation Table

| Cycle | Node 1 State | Node 2 State | Goal | Shared Q | Delta Action | Behavior |
|:------|:--------------|:--------------|:------|:-----------|:--------------|:--------------|
| 1 | 45 | 180 | 128 | 120 | 42 | Divergent start |
| 5 | 100 | 140 | 128 | 125 | 18 | Cooperative adjustment |
| 10 | 128 | 130 | 128 | 128 | 2 | Goal alignment |
| 15 | 127 | 129 | 128 | 128 | 1 | Stable consensus |

---

## 💡 8. Discussion Points

- How does **shared-Q synchronization** accelerate convergence?  
- Compare **individual vs collective reinforcement** performance.  
- How does **Neo4j graph topology** reflect collective cognition?  
- What happens when a node goes offline — can others maintain stability?  

---

## 🧠 9. Post-Lab Exercises

- Incorporate **trust weighting** (from Lab 27) into shared knowledge updates.  
- Introduce **multi-goal negotiation** (energy vs accuracy).  
- Add **quantum randomness** (from Lab 26) for enhanced exploration.  
- Model **agent specialization** using distinct Q-update policies.  
- Visualize **collective learning evolution** in Node-RED or Python charts.  

---

## 🧾 10. Outcome

Students will be able to:
- Implement **distributed cognition** and **collective reinforcement** on FPGAs.  
- Synchronize shared knowledge across multiple agents.  
- Analyze **goal convergence** and **emergent coordination**.  
- Understand **CPS 10.0 – Collective Cognitive Intelligence** architecture.  

---

## 📘 11. References

- Russell & Norvig, *Artificial Intelligence: A Modern Approach*, 2021.  
- Mittal, S., *Cognitive FPGA Swarms for Edge Intelligence*, IEEE Access, 2025.  
- Tao et al., *Digital Twins and Collective Learning in CPS*, IEEE TII, 2023.  
- Lee & Seshia, *Embedded Systems: A CPS Approach*.  
- Palnitkar, *Verilog HDL: A Guide to Digital Design and Synthesis*.  

---

✅ **Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** 1st Edition (2025)  
**License:** CC BY-NC 4.0  
