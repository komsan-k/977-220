# 🌐 Lab: Building an HTTP Endpoint for ESP32 Using Node-RED

## 🧩 1. Objective

This laboratory exercise demonstrates how to create an **HTTP-based IoT data ingestion server** using **Node-RED** and connect it with an **ESP32** client.  
Students will learn to:

- Design and deploy a simple HTTP REST endpoint using Node-RED.  
- Ingest counter values from an ESP32 via HTTP GET requests.  
- Store device data using Node-RED’s *flow context* memory.  
- Query stored results and view statistics via a second HTTP endpoint.

---

## ⚙️ 2. Background

### 2.1 Node-RED Overview
**Node-RED** is a low-code development environment for wiring together devices, APIs, and online services.  
Its flow-based programming model enables rapid prototyping of IoT data pipelines.

Typical Node-RED use cases include:
- IoT device data collection and processing.  
- Dashboard visualization.  
- Integration with MQTT, HTTP, or WebSocket protocols.

### 2.2 HTTP in IoT
**HTTP (Hypertext Transfer Protocol)** provides a standardized interface for data exchange between IoT nodes and cloud applications.  
This lab focuses on implementing:
- **GET /ingest** → to receive counter data from the ESP32.  
- **GET /metrics** → to display stored device records.

---

## 🔌 3. Required Hardware

| Component | Description |
|------------|-------------|
| ESP32 Dev Board | NodeMCU-32S, ESP-WROOM-32, or equivalent |
| Computer or Raspberry Pi | Running Node-RED |
| Wi-Fi Network | Same LAN for both ESP32 and Node-RED |

---

## 🧰 4. Required Software

| Tool | Purpose |
|------|----------|
| Node-RED | IoT flow server |
| Arduino IDE | ESP32 programming |
| `curl` | Command-line testing |
| Web Browser | For viewing `/metrics` JSON output |

---

## 🧠 5. Node-RED Flow Configuration

### 5.1 Importing the Flow
1. Open the **Node-RED Editor** at `http://<NODE_RED_IP>:1880`.  
2. Click **Menu → Import → Clipboard**.  
3. Paste the JSON flow and click **Import → Deploy**.

---

## 🧪 6. ESP32 Client Configuration

### 6.1 Server URL Setup
Update your ESP32 sketch to point to the Node-RED server:

```cpp
const char* serverURL = "http://<NODE_RED_IP>:1880/ingest"; // e.g., http://192.168.1.50:1880/ingest
```

### 6.2 Example Request
The ESP32 will send requests like:

```
http://192.168.1.50:1880/ingest?device_id=esp32&count=42
```

---

## 🧰 7. Local Testing (without ESP32)

You can manually test your endpoints using `curl`:

```bash
curl "http://192.168.1.50:1880/ingest?device_id=esp32&count=0"
curl "http://192.168.1.50:1880/ingest?device_id=esp32&count=1"
curl "http://192.168.1.50:1880/metrics"
```

Each request will return a JSON confirmation with stored data.

---

## 💾 8. Data Persistence (Optional)

By default, flow context is stored in RAM.  
To make it persistent:

1. Edit your Node-RED `settings.js` file:
   ```js
   contextStorage: {
     default: { module: "localfilesystem" }
   }
   ```
2. Restart Node-RED.  
3. In your Function node, use:
   ```js
   let devices = flow.get('devices', 'default') || {};
   flow.set('devices', devices, 'default');
   ```

---

## 🔐 9. Security Enhancements (Recommended)

When exposing the service outside the LAN:

1. **Use HTTPS** via a reverse proxy (e.g., Nginx, Caddy).  
2. **Add an API key check** inside your Function node:

   ```js
   const apiKey = msg.req.headers["x-api-key"];
   if (apiKey !== "YOUR_SECRET") {
       msg.statusCode = 401;
       msg.payload = { error: "Unauthorized" };
       return msg;
   }
   ```

3. Restrict access by IP or VPN connection.

---

## 📊 10. Observations

- The `/ingest` endpoint receives and logs the counter value.  
- The `/metrics` endpoint displays a summary of all device data stored.  
- Each new request increments the hit counter.  
- Data persists if file-based context is configured.

---

## 🧾 11. Summary

This lab provides practical experience in **building RESTful IoT endpoints** using **Node-RED**.  
It demonstrates a complete workflow:
1. ESP32 generates HTTP requests.  
2. Node-RED ingests and stores the data.  
3. Results are viewed and managed through a REST API.  

This structure serves as a foundation for scalable IoT dashboards, analytics, and digital-twin frameworks.

---

## ✍️ 12. Author

**Author:** Dr. Komsan Kanjanasit  
**Publisher:** College of Computing, Prince of Songkla University, Thailand  
**Edition:** First Edition (2025)  
**ISBN (e-book):** 978-616-271-830-4

---

## 📚 13. References

1. Node-RED Documentation — [https://nodered.org/docs/](https://nodered.org/docs/)  
2. ESP32 Arduino Core — [https://docs.espressif.com/](https://docs.espressif.com/)  
3. MQTT vs HTTP in IoT — [https://www.hivemq.com](https://www.hivemq.com)  
4. Nginx Reverse Proxy Guide — [https://nginx.org](https://nginx.org)
