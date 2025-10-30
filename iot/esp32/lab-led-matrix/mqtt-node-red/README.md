
# 🔬 Lab Extension: ESP32 HT16K33 Matrix with **MQTT (HiveMQ)** + **Node‑RED Dashboard (Slider Control)**

> This builds on the base lab (ESP32 + HT16K33 8×16 Matrix counter) by adding **cloud control via MQTT** and a **Node‑RED Dashboard** with sliders to control **number**, **brightness**, and **update interval** in real time.

---

## 🎯 Objectives
- Connect ESP32 to the public **HiveMQ** MQTT broker and exchange JSON payloads.
- Subscribe to **command topics** to control the matrix display from the cloud.
- Publish **status topics** for telemetry (number, brightness, RSSI, uptime).
- Build a **Node‑RED dashboard** with sliders to control the matrix:
  - `number` (0–99)
  - `brightness` (0–15)
  - `interval_ms` (100–2000 ms)
- Support two modes on ESP32: **auto_count** and **manual**.

---

## 🧱 System Architecture

```
[Node‑RED Dashboard] <--MQTT--> [HiveMQ Broker] <--MQTT--> [ESP32 + HT16K33]
     (sliders)                     broker.hivemq.com:1883           (matrix)
```

---

## 🧩 Topics & Payloads (JSON)

| Direction | Topic | Example Payload | Purpose |
|---|---|---|---|
| ⬇️ to ESP32 | `esp32/matrix/cmd/number` | `{"number":42}` | Set display to a specific number (0–99) |
| ⬇️ to ESP32 | `esp32/matrix/cmd/brightness` | `{"brightness":12}` | Set brightness (0–15) |
| ⬇️ to ESP32 | `esp32/matrix/cmd/interval_ms` | `{"interval_ms":750}` | Set auto-count interval in ms |
| ⬇️ to ESP32 | `esp32/matrix/cmd/mode` | `{"auto_count":true}` | Toggle auto count vs manual |
| ⬆️ from ESP32 | `esp32/matrix/status` | `{"number":42,"brightness":12,"auto_count":true,"rssi":-56,"uptime_s":123}` | Periodic status heartbeat |
| ⬆️ from ESP32 | `esp32/matrix/echo` | `{"cmd":"number","ok":true,"value":42}` | Acknowledge last command |

> Note: Messages are simple JSON objects for readability in tools like Node‑RED and MQTT clients.

---

## 🧰 Prerequisites
- **Arduino IDE** (or PlatformIO) with:
  - ESP32 core installed
  - Libraries: `Adafruit GFX`, `Adafruit LED Backpack`, `PubSubClient`
- **Node‑RED** (with `node-red-dashboard` installed)
- Internet access to public MQTT broker: `broker.hivemq.com:1883`

---

## 🔌 Wiring Recap
| ESP32 | HT16K33 |
|---|---|
| 3V3 | VCC |
| GND | GND |
| GPIO21 | SDA |
| GPIO22 | SCL |

---

## 💻 ESP32 Firmware (MQTT + Matrix)

> Replace `YOUR_WIFI_SSID` / `YOUR_WIFI_PASSWORD` before uploading.

```cpp
#include <Wire.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <Adafruit_GFX.h>
#include <Adafruit_LEDBackpack.h>

// ===== User Config =====
const char* ssid     = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const char* mqtt_host = "broker.hivemq.com";
const int   mqtt_port = 1883;

// Topics
const char* T_CMD_NUMBER      = "esp32/matrix/cmd/number";
const char* T_CMD_BRIGHTNESS  = "esp32/matrix/cmd/brightness";
const char* T_CMD_INTERVAL    = "esp32/matrix/cmd/interval_ms";
const char* T_CMD_MODE        = "esp32/matrix/cmd/mode";
const char* T_STATUS          = "esp32/matrix/status";
const char* T_ECHO            = "esp32/matrix/echo";

// ===== Globals =====
Adafruit_8x16matrix matrix = Adafruit_8x16matrix();
WiFiClient espClient;
PubSubClient mqtt(espClient);

int numberVal = 0;           // 0..99
int brightnessVal = 8;       // 0..15
unsigned long intervalMs = 1000; // auto-count interval
bool autoCount = true;       // mode
unsigned long lastTick = 0;
unsigned long lastStatus = 0;

String ipStr;

void showNumberSwapped(int n) {
  if (n < 0) n = 0;
  if (n > 99) n = 99;
  int tens = n / 10;
  int ones = n % 10;

  matrix.clear();
  matrix.setTextSize(1);
  matrix.setTextColor(LED_ON);
  // Ones on left, tens on right (swapped positions)
  matrix.setCursor(0, 0);
  matrix.print(ones);
  matrix.setCursor(8, 0);
  matrix.print(tens);
  matrix.writeDisplay();
}

static int jsonGetInt(const String& s, const char* key, int defaultVal) {
  // minimal JSON int extractor, expects {"key":value}
  int i = s.indexOf(key);
  if (i < 0) return defaultVal;
  int colon = s.indexOf(':', i);
  if (colon < 0) return defaultVal;
  int start = colon + 1;
  while (start < (int)s.length() && (s[start]==' '||s[start]=='"')) start++;
  // read number (may end at , or })
  int end = start;
  while (end < (int)s.length() && (isdigit(s[end]) || s[end]=='-')) end++;
  return s.substring(start, end).toInt();
}

static bool jsonGetBool(const String& s, const char* key, bool defVal) {
  int i = s.indexOf(key);
  if (i < 0) return defVal;
  int colon = s.indexOf(':', i);
  if (colon < 0) return defVal;
  int start = colon + 1;
  while (start < (int)s.length() && (s[start]==' '||s[start]=='"')) start++;
  if (s.startsWith("true", start)) return true;
  if (s.startsWith("false", start)) return false;
  return defVal;
}

void publishStatus() {
  long rssi = WiFi.RSSI();
  unsigned long uptime = millis() / 1000;
  char buf[200];
  snprintf(buf, sizeof(buf),
    "{"number":%d,"brightness":%d,"auto_count":%s,"rssi":%ld,"uptime_s":%lu}",
    numberVal, brightnessVal, autoCount ? "true":"false", rssi, uptime);
  mqtt.publish(T_STATUS, buf);
}

void echoCmd(const char* cmd, int value, bool ok=true) {
  char buf[128];
  snprintf(buf, sizeof(buf), "{"cmd":"%s","ok":%s,"value":%d}", cmd, ok?"true":"false", value);
  mqtt.publish(T_ECHO, buf);
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  String msg;
  msg.reserve(length+1);
  for (unsigned int i=0; i<length; i++) msg += (char)payload[i];

  if (!strcmp(topic, T_CMD_NUMBER)) {
    int v = jsonGetInt(msg, "number", numberVal);
    numberVal = constrain(v, 0, 99);
    showNumberSwapped(numberVal);
    echoCmd("number", numberVal);
  } else if (!strcmp(topic, T_CMD_BRIGHTNESS)) {
    int v = jsonGetInt(msg, "brightness", brightnessVal);
    brightnessVal = constrain(v, 0, 15);
    matrix.setBrightness(brightnessVal);
    showNumberSwapped(numberVal);
    echoCmd("brightness", brightnessVal);
  } else if (!strcmp(topic, T_CMD_INTERVAL)) {
    int v = jsonGetInt(msg, "interval_ms", intervalMs);
    intervalMs = constrain(v, 100, 5000);
    echoCmd("interval_ms", intervalMs);
  } else if (!strcmp(topic, T_CMD_MODE)) {
    bool v = jsonGetBool(msg, "auto_count", autoCount);
    autoCount = v;
    echoCmd("auto_count", autoCount ? 1:0);
  }

  publishStatus();
}

void ensureMqtt() {
  while (!mqtt.connected()) {
    String cid = String("esp32-matrix-") + String((uint32_t)ESP.getEfuseMac(), HEX);
    if (mqtt.connect(cid.c_str())) {
      mqtt.subscribe(T_CMD_NUMBER);
      mqtt.subscribe(T_CMD_BRIGHTNESS);
      mqtt.subscribe(T_CMD_INTERVAL);
      mqtt.subscribe(T_CMD_MODE);
      publishStatus();
    } else {
      delay(1500);
    }
  }
}

void setup() {
  Serial.begin(115200);
  delay(100);
  // Display
  Wire.begin(21,22);
  matrix.begin(0x70);
  matrix.setBrightness(brightnessVal);
  showNumberSwapped(numberVal);

  // Wi‑Fi
  WiFi.begin(ssid, password);
  Serial.print("WiFi connecting");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500); Serial.print(".");
  }
  ipStr = WiFi.localIP().toString();
  Serial.printf("\nWiFi OK, IP: %s\n", ipStr.c_str());

  // MQTT
  mqtt.setServer(mqtt_host, mqtt_port);
  mqtt.setCallback(mqttCallback);
  ensureMqtt();
  publishStatus();
}

void loop() {
  if (!mqtt.connected()) ensureMqtt();
  mqtt.loop();

  unsigned long now = millis();

  // auto counter
  if (autoCount && now - lastTick >= intervalMs) {
    lastTick = now;
    numberVal = (numberVal + 1) % 100;
    showNumberSwapped(numberVal);
  }

  // heartbeat every 5s
  if (now - lastStatus >= 5000) {
    lastStatus = now;
    publishStatus();
  }
}
```

---

## 🧱 Node‑RED Flow (Import JSON)

> This flow creates a Dashboard with **three sliders** and **status text**. It publishes slider values to command topics and shows ESP32 status.

1. In Node‑RED, install `node-red-dashboard` (Manage Palette → Install).
2. Import this flow (Menu → Import → Clipboard → Paste JSON → Import).
3. Open Dashboard (default: `http://localhost:1880/ui`).

```json
[
  {
    "id": "f-broker",
    "type": "mqtt-broker",
    "name": "HiveMQ",
    "broker": "broker.hivemq.com",
    "port": "1883",
    "clientid": "nodered-matrix-dashboard",
    "usetls": false,
    "protocolVersion": "4",
    "keepalive": "60",
    "cleansession": true,
    "birthTopic": "",
    "birthQos": "0",
    "birthPayload": "",
    "closeTopic": "",
    "closeQos": "0",
    "closePayload": "",
    "willTopic": "",
    "willQos": "0",
    "willPayload": ""
  },
  {
    "id": "ui_tab",
    "type": "ui_tab",
    "name": "Matrix Control",
    "icon": "dashboard",
    "disabled": false,
    "hidden": false
  },
  {
    "id": "ui_group",
    "type": "ui_group",
    "z": "",
    "name": "Controls",
    "tab": "ui_tab",
    "order": 1,
    "disp": true,
    "width": "6",
    "collapse": false
  },
  {
    "id": "ui_group2",
    "type": "ui_group",
    "z": "",
    "name": "Status",
    "tab": "ui_tab",
    "order": 2,
    "disp": true,
    "width": "6",
    "collapse": false
  },
  {
    "id": "slider_number",
    "type": "ui_slider",
    "z": "",
    "name": "Number",
    "label": "Number (0-99)",
    "tooltip": "",
    "group": "ui_group",
    "order": 1,
    "width": 6,
    "height": 1,
    "passthru": true,
    "outs": "all",
    "topic": "esp32/matrix/cmd/number",
    "min": 0,
    "max": 99,
    "step": 1,
    "x": 0,
    "y": 0,
    "wires": [["fn_number_to_json"]]
  },
  {
    "id": "slider_brightness",
    "type": "ui_slider",
    "z": "",
    "name": "Brightness",
    "label": "Brightness (0-15)",
    "group": "ui_group",
    "order": 2,
    "width": 6,
    "height": 1,
    "passthru": true,
    "outs": "all",
    "topic": "esp32/matrix/cmd/brightness",
    "min": 0,
    "max": 15,
    "step": 1,
    "x": 0,
    "y": 0,
    "wires": [["fn_brightness_to_json"]]
  },
  {
    "id": "slider_interval",
    "type": "ui_slider",
    "z": "",
    "name": "Interval",
    "label": "Interval (ms)",
    "group": "ui_group",
    "order": 3,
    "width": 6,
    "height": 1,
    "passthru": true,
    "outs": "all",
    "topic": "esp32/matrix/cmd/interval_ms",
    "min": 100,
    "max": 2000,
    "step": 50,
    "x": 0,
    "y": 0,
    "wires": [["fn_interval_to_json"]]
  },
  {
    "id": "switch_mode",
    "type": "ui_switch",
    "z": "",
    "name": "Auto Count",
    "label": "Auto Count",
    "group": "ui_group",
    "order": 4,
    "width": 6,
    "height": 1,
    "passthru": true,
    "topic": "esp32/matrix/cmd/mode",
    "style": "",
    "onvalue": "true",
    "offvalue": "false",
    "x": 0,
    "y": 0,
    "wires": [["fn_mode_to_json"]]
  },
  {
    "id": "fn_number_to_json",
    "type": "function",
    "name": "number -> JSON",
    "func": "msg.payload = JSON.stringify({number: Number(msg.payload)});
msg.topic = 'esp32/matrix/cmd/number';
return msg;",
    "outputs": 1,
    "noerr": 0,
    "initialize": "",
    "finalize": "",
    "libs": []
  },
  {
    "id": "fn_brightness_to_json",
    "type": "function",
    "name": "brightness -> JSON",
    "func": "msg.payload = JSON.stringify({brightness: Number(msg.payload)});
msg.topic = 'esp32/matrix/cmd/brightness';
return msg;",
    "outputs": 1
  },
  {
    "id": "fn_interval_to_json",
    "type": "function",
    "name": "interval -> JSON",
    "func": "msg.payload = JSON.stringify({interval_ms: Number(msg.payload)});
msg.topic = 'esp32/matrix/cmd/interval_ms';
return msg;",
    "outputs": 1
  },
  {
    "id": "fn_mode_to_json",
    "type": "function",
    "name": "mode -> JSON",
    "func": "const v = (msg.payload === true || msg.payload === 'true');
msg.payload = JSON.stringify({auto_count: v});
msg.topic = 'esp32/matrix/cmd/mode';
return msg;",
    "outputs": 1
  },
  {
    "id": "mqtt_out",
    "type": "mqtt out",
    "name": "to ESP32 (cmd)",
    "topic": "",
    "qos": "",
    "retain": "",
    "broker": "f-broker",
    "x": 0,
    "y": 0,
    "wires": []
  },
  {
    "id": "mqtt_in_status",
    "type": "mqtt in",
    "name": "ESP32 status",
    "topic": "esp32/matrix/status",
    "qos": "0",
    "datatype": "auto",
    "broker": "f-broker",
    "nl": false,
    "rap": false,
    "rh": 0,
    "x": 0,
    "y": 0,
    "wires": [["fn_pretty_status","ui_text_status"]]
  },
  {
    "id": "fn_pretty_status",
    "type": "function",
    "name": "pretty",
    "func": "try{
  const o = JSON.parse(msg.payload);
  msg.payload = `#${o.number} | b:${o.brightness} | auto:${o.auto_count} | rssi:${o.rssi} | up:${o.uptime_s}s`;
}catch(e){}
return msg;",
    "outputs": 1
  },
  {
    "id": "ui_text_status",
    "type": "ui_text",
    "name": "Status",
    "group": "ui_group2",
    "order": 1,
    "width": 6,
    "height": 1,
    "label": "ESP32 Status",
    "format": "{{msg.payload}}",
    "layout": "row-spread"
  },
  {
    "id": "link1",
    "type": "link",
    "z": "",
    "links": ["slider_number","slider_brightness","slider_interval","switch_mode","mqtt_out","fn_number_to_json","fn_brightness_to_json","fn_interval_to_json","fn_mode_to_json","mqtt_in_status","fn_pretty_status","ui_text_status"]
  }
]
```

> After import, wire each `function` node into the **single** `mqtt out` node (to publish commands). Some editors auto-wire on import; verify visually.

---

## ▶️ Test Procedure
1. **Flash ESP32** with the firmware above and open Serial Monitor (115200). Confirm Wi‑Fi + MQTT connect and periodic status publishes.
2. **Start Node‑RED** and open the **Dashboard**. Move sliders/toggle:
   - Number → display should update immediately.
   - Brightness → visible change (0–15).
   - Interval → affects auto count speed.
   - Auto Count → toggle manual vs automatic.
3. Observe **ESP32 Status** text updating every ~5 seconds.

---

## 🧪 Experiments
- Add a **text input** in Node‑RED to publish `{"number": <n>}`.
- Add a **chart** node to plot `number` over time from `esp32/matrix/status`.
- Add a **retain** flag on command topics to initialize values after ESP32 reboot.

---

## 🛡️ Security Notes
- Public brokers are **unauthenticated**; anyone can read/write to your topics.
- For production, use a private broker with **TLS**, **username/password**, and **topic ACLs**.
- Use a unique topic prefix, e.g., `psu/{your_id}/esp32/matrix/...`

---

## 🆘 Troubleshooting
| Symptom | Likely Cause | Fix |
|---|---|---|---|
| Node‑RED sliders do nothing | Wrong topic or not wired to MQTT out | Confirm function → mqtt out wiring and topic strings |
| ESP32 not connecting to MQTT | Wi‑Fi credentials or firewall | Check SSID/PW and allow outbound port 1883 |
| Display not changing | JSON malformed | Use valid JSON: e.g., `{ "brightness": 12 }` |
| Flicker/ghosting | Power dips | Use stable 3.3V and keep brightness < 15 |

---

## ✅ Learning Outcomes
- Built an **IoT loop**: device ↔ broker ↔ dashboard.
- Implemented topic design and **bidirectional MQTT**.
- Deployed a **cloud‑controlled display** with **live telemetry**.
