# 🧭 Checkpoint & Evaluation Criteria
### Lab: ESP32 MQTT JSON Publisher with RSSI Monitoring

This document defines the checkpoint and grading criteria for completing the **ESP32 MQTT JSON Publisher with RSSI Monitoring** lab.  
Students are evaluated based on **timeliness** and **functionality** of their work.

---

## ⏱️ 1. Submission Timeline & Scoring

| **Completion Time** | **Performance Level** | **Score Allocation** | **Remarks** |
|----------------------|-----------------------|----------------------|--------------|
| ✅ **Before 10:00 AM** | Excellent (on-time) | **4.0% (maximum)** | Completed and verified early |
| 🕐 **10:00 – 10:15 AM** | Slightly late | 3.7% | -0.3% penalty |
| 🕐 **10:15 – 10:30 AM** | Minor delay | 3.4% | -0.6% penalty |
| 🕐 **10:30 – 10:45 AM** | Moderate delay | 3.1% | -0.9% penalty |
| 🕐 **10:45 – 11:00 AM** | Noticeable delay | 2.8% | -1.2% penalty |
| 🕐 **11:00 – 11:15 AM** | Late submission | 2.5% | -1.5% penalty |
| 🕐 **11:15 – 11:30 AM** | Late submission | 2.2% | -1.8% penalty |
| 🕐 **11:30 – 11:45 AM** | Very late | 1.9% | -2.1% penalty |
| 🕐 **11:45 – 12:00 PM** | Very late | 1.6% | -2.4% penalty |
| ❌ **After 12:00 PM** | Not accepted | 0% | Submission closed |

> ⏳ **Time deduction rule:** After **10:00 AM**, the score is reduced **every 15 minutes by 0.3%**, up to **12:00 PM**.  
> 🕕 No scores are awarded for submissions **after 12:00 PM**.

---

## 🧩 2. Completion Criteria

To be considered **complete**, your lab must meet all of the following checkpoints:

| **Checkpoint** | **Description** | **Verification Method** |
|----------------|------------------|--------------------------|
| 1️⃣ Code Compiles Successfully | No errors or missing libraries | Arduino IDE compile output |
| 2️⃣ MQTT Connection Established | ESP32 connects to HiveMQ broker | Serial monitor shows “connected” |
| 3️⃣ JSON Data Published | Temperature, LDR, and RSSI values published to topic | HiveMQ dashboard displays payload |
| 4️⃣ RSSI Integrated | JSON payload includes `"rssi_dbm"` field | Serial log and MQTT verification |
| 5️⃣ Serial Output Verified | RSSI and sensor data displayed correctly | Screenshot or instructor check |
| 6️⃣ Discussion / Reflection | Student explains signal variation vs. distance | Short verbal or written summary |

---

## 📊 3. Example Evaluation Rubric

| **Component** | **Weight (%)** | **Description** |
|----------------|----------------|----------------|
| Functionality | 40% | JSON payload includes LDR, Temperature, RSSI |
| MQTT Connectivity | 20% | Stable broker connection and topic publish |
| Code Quality | 20% | Clear comments, readable structure |
| Verification & Demonstration | 10% | Output verified via Serial and MQTT |
| Timeliness | 10% | Based on time checkpoint table |

---

## 🧠 Instructor Notes
- Each 15-minute interval after **10:00 AM** reduces the lab grade linearly until **12:00 PM**.  
- Early finishers (before 10:00 AM) earn **full 4%**.  
- Ensure students document proof of MQTT message and RSSI variation.  
- Encourage screenshots or short videos of HiveMQ output for bonus clarity.

---

**End of Checkpoint Criteria Document**
