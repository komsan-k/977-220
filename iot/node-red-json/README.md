# Understanding JSON in Node-RED (for MQTT & IoT)

JSON is everywhere in IoT. Most MQTT payloads, REST APIs, and Node-RED messages use **JSON (JavaScript Object Notation)** because it’s compact, readable, and universally supported. This guide shows **what JSON is**, **how Node-RED handles it**, and includes a **ready-to-import example flow** for receiving, parsing, visualizing, and publishing JSON.

---

## Why JSON for IoT?

- **Human + machine friendly:** easy to read/write.
- **Lightweight:** great for low-bandwidth links.
- **Cross-language:** works with Python, C/C++, JavaScript, etc.
- **Native to Node-RED:** flows pass data as JavaScript objects, commonly JSON in `msg.payload`.

---

## 1) What is JSON?

A text format for key–value data:

```json
{
  "temperature": 28.5,
  "humidity": 65,
  "status": "ON"
}
```

---

## 2) How Node-RED Carries Data

Node-RED passes data between nodes via a **message object** called `msg`.  
Typical structure:

```js
msg = {
  payload: { temperature: 27.5, humidity: 60 },
  topic: "test/sensor/data"
}
```

- `msg.payload` → main data (often a JSON object or a stringified JSON)
- `msg.topic`   → MQTT topic/category for routing

---

## 3) Receiving JSON (e.g., from MQTT/HTTP)

MQTT brokers often deliver payloads as **strings**, e.g.:

```json
{"temperature": 29.3, "state": "ON"}
```

### Convert the text into a usable object
1. `mqtt in` → **outputs text by default**  
2. **Add a `json` node** right after it → parses text → JavaScript object  
3. Now downstream nodes (Function, Change, Dashboard) can use fields like `msg.payload.temperature`.

**Flow idea:**  
`[mqtt in] → [json] → [function/change] → [gauge/chart/debug]`

---

## 4) Sending JSON (to MQTT or an API)

You can create JSON payloads using:
- **Change node:** set `msg.payload` to an object literal
- **Function node:** build and `return msg;`

**Change node (set `msg.payload`):**
```json
{
  "state": "OFF",
  "press_count": 3
}
```

**Function node:**
```js
msg.payload = { state: "ON", press_count: 5 };
return msg;
```

Sending via `mqtt out` will automatically stringify the JSON.

---

## 5) Typical JSON Flow (End-to-End)

| Node        | Function                               | Example Output                                           |
|-------------|-----------------------------------------|----------------------------------------------------------|
| MQTT In     | Receives text                           | `"{"temperature":26.3,"humidity":58}"` (string)         |
| JSON        | Text → object                           | `{ temperature: 26.3, humidity: 58 }`                    |
| Change      | Extract a field                         | `msg.payload = msg.payload.temperature` → `26.3`         |
| Gauge       | Visualizes a value                      | shows `26.3 °C`                                          |
| MQTT Out    | Publishes a control JSON                | `{"state":"ON","press_count":4}`                         |

---

## 6) Debugging JSON in Node-RED

- Use **Debug** node → **complete msg object**  
- Check whether your data is still a string or already parsed JSON
- Inspect nested fields, e.g. `msg.payload.temperature`

---

## 7) Common JSON Mistakes (and Fixes)

| Mistake            | Example                 | Fix                      |
|--------------------|-------------------------|--------------------------|
| Missing quotes     | `{temperature: 25}`     | `{"temperature": 25}`    |
| Trailing comma     | `{"a":1,}`              | `{"a":1}`                |
| Sending as text    | `"{"state":"ON"}"`      | Build an object, not a quoted string |
| Single quotes      | `{'state':'ON'}`        | Use **double** quotes    |

---

## 8) Example: JSON Command Round-Trip

**Node-RED publishes:**
```json
{
  "state": "ON",
  "press_count": 2
}
```

**Python subscriber prints:**
```
📥 Received from device/control/state: {"state":"ON","press_count":2}
🟢 Device Command: State set to ON
```

---

## 9) Ready-to-Import Node-RED Flow (MQTT + JSON + Dashboard)

**What it does**
- Subscribes to `test/sensor/temperature` on `broker.hivemq.com`
- Parses text payload → number
- Shows **Gauge** + **Chart** + “Last Reading”
- Publishes JSON control commands (toggle ON/OFF + press count) to `device/control/state`

### How to import
1. Download `flow.json` in this folder.
2. Node-RED: **Menu → Import → Clipboard** → paste file contents → **Import**  
3. **Deploy**  
4. Open dashboard: **http://localhost:1880/ui**

---

## 10) TL;DR

- **JSON** is the lingua franca of IoT messages.  
- In **Node-RED**, use the **JSON node** to convert between text and objects.  
- Build and modify JSON with **Change** or **Function** nodes.  
- **MQTT nodes** subscribe/publish JSON seamlessly.  
- Use **Debug** to inspect the full `msg` at any point.
