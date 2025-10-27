# 🌐 Implementing IoT Topic Design (MQTT-Based Architecture)

## 🧭 1. Overview
In MQTT-based IoT systems, a **topic** acts as a logical address for communication between devices and applications.  
A well-designed topic hierarchy enables scalability, security, and efficient data routing in large IoT deployments.

Example:
```
v1/psu/thailand/phuket/esp32_a1/temperature
```

This hierarchy defines:
- **version** → `v1`
- **organization** → `psu`
- **region** → `thailand`
- **site** → `phuket`
- **device** → `esp32_a1`
- **data type** → `temperature`

---

## ⚙️ 2. Step-by-Step Implementation Workflow

### **Step 1: Define the Topic Schema**
Design a consistent structure:
```
<version>/<organization>/<region>/<site>/<device_id>/<data_type>
```

| Level | Meaning | Example |
|--------|----------|----------|
| version | Schema version | v1 |
| organization | Organization name | psu |
| region | Country or area | thailand |
| site | Deployment location | phuket |
| device_id | Unique device name | esp32_a1 |
| data_type | Sensor or data stream | temperature |

---

### **Step 2: Implement Topics in MQTT Broker**
Configure your MQTT broker (e.g., Mosquitto, HiveMQ, EMQX).

**Example Configuration:**
```conf
listener 1883 0.0.0.0
protocol mqtt
allow_anonymous false
password_file /etc/mosquitto/passwd
acl_file /etc/mosquitto/acl
```

**Access Control Example (ACL):**
```conf
user esp32_a1
topic write v1/psu/thailand/phuket/esp32_a1/#
topic read  v1/psu/thailand/phuket/esp32_a1/control
```

This enforces **topic ownership** — each device can only write to its assigned branch.

---

### **Step 3: Implement Topics on Devices (ESP32 Example)**
Each device should know its publish and subscribe topics.

```cpp
const char* pub_topic = "v1/psu/thailand/phuket/esp32_a1/sensor_data";
const char* sub_topic = "v1/psu/thailand/phuket/esp32_a1/control";

client.publish(pub_topic, json_payload);
client.subscribe(sub_topic);
```

**JSON Payload Example:**
```json
{
  "temperature_c": 25.3,
  "ldr_raw": 2100,
  "device_id": "esp32_a1",
  "timestamp": "2025-10-28T04:00:00Z"
}
```

---

### **Step 4: Implement Topics in Node-RED**
1. Add **MQTT In** node → subscribe to `v1/psu/#`  
2. Add **Switch** node → filter by `msg.payload.device_id`  
3. Add **Chart** or **Gauge** nodes → visualize temperature or LDR values  

**Node-RED Subscription Example:**
```
v1/psu/thailand/phuket/esp32_a1/#
```

---

### **Step 5: Use Wildcards for Efficient Subscriptions**

| Symbol | Scope | Example | Matches |
|---------|--------|----------|----------|
| `+` | One level | `v1/psu/thailand/+/esp32_a1/#` | All A1 nodes across sites |
| `#` | Multi-level | `v1/psu/#` | All devices under PSU |

---

### **Step 6: Manage Scalability**
For large deployments:
- Cluster brokers (HiveMQ, EMQX, Mosquitto bridge)
- Distribute traffic by region or topic prefix
- Load balance device connections

Example distribution:
```
phuket/#   → broker1
hatyai/#   → broker2
```

---

## 🧠 3. Real Example in Practice

### Topic Tree
```
v1/
 └─ psu/
    └─ thailand/
       ├─ phuket/
       │  ├─ esp32_a1/
       │  │  ├─ temperature
       │  │  └─ ldr
       │  └─ esp32_b2/
       │     ├─ temperature
       │     └─ ldr
       └─ hatyai/
          └─ esp32_c7/
             ├─ temperature
             └─ ldr
```

### Example ACL
```text
user esp32_a1
topic write v1/psu/thailand/phuket/esp32_a1/#
topic read  v1/psu/thailand/phuket/esp32_a1/control
```

---

### Example Node-RED Flow
- MQTT In → `v1/psu/thailand/phuket/#`
- Switch → filter `device_id`
- Chart → temperature display per device

---

## ☁️ 4. Cloud Integration and Digital Twin

MQTT topics can map directly to **cloud IoT shadows**:
```
$aws/things/<device_id>/shadow/update
$aws/things/<device_id>/shadow/get
```

These synchronize device state between physical and digital twins for control, analytics, or AI services.

---

## 📘 5. Implementation Summary

| Stage | Component | Implementation |
|--------|------------|----------------|
| 1 | Topic schema design | Define hierarchy (organization → site → device → data) |
| 2 | Broker setup | Configure listener, ACLs, and credentials |
| 3 | Device firmware | Publish/subscribe using defined topics |
| 4 | Middleware | Subscribe using wildcards, route by payload |
| 5 | Cloud bridge | Map MQTT to IoT twin topics |
| 6 | Monitoring | Use Node-RED or Grafana for dashboards |

---

## 💡 Key Takeaway

> IoT topic design is **the architecture of communication**.  
A good design ensures scalability, security, and interoperability from prototype labs to industrial-scale IoT deployments.
