# Lab 7: Controlling ESP32 via Node-RED Dashboard

## Objective
- Use Node-RED to create a simple web-based dashboard for controlling an ESP32.
- Send MQTT messages from Node-RED to toggle an LED on the ESP32.
- Understand the integration of low-code tools in IoT systems.

## Required Hardware and Software
- ESP32 development board.
- LED and 220 Ω resistor.
- Breadboard and jumper wires.
- Computer with Arduino IDE.
- Local Wi-Fi network.
- MQTT broker (public or local Mosquitto).
- Node-RED installed on PC or Raspberry Pi.
- Node-RED Dashboard nodes installed (`node-red-dashboard`).
- Web browser for dashboard access.
- Arduino libraries:
  - `WiFi.h`
  - `PubSubClient`

## Background Theory
Node-RED is a flow-based programming tool for wiring together hardware devices, APIs, and online services.  
With the Dashboard extension, interactive web interfaces can be created for IoT device control without writing HTML or JavaScript.

In this lab:
1. The ESP32 subscribes to an MQTT topic for LED control.
2. Node-RED sends MQTT messages when dashboard buttons are pressed.

## Procedure

1. **Wire the LED:**
   - LED anode → GPIO 5 via 220 Ω resistor.
   - LED cathode → GND.

2. **Arduino Sketch for ESP32:**
```cpp
#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "Your_SSID";
const char* password = "Your_PASSWORD";

const char* mqtt_server = "test.mosquitto.org";
const int mqtt_port = 1883;
const char* sub_topic = "lab7/ledcontrol";

WiFiClient espClient;
PubSubClient client(espClient);

#define LED_PIN 5

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void callback(char* topic, byte* message, unsigned int length) {
  String msg;
  for (int i = 0; i < length; i++) {
    msg += (char)message[i];
  }
  if (msg == "ON") {
    digitalWrite(LED_PIN, HIGH);
    Serial.println("LED ON");
  } else if (msg == "OFF") {
    digitalWrite(LED_PIN, LOW);
    Serial.println("LED OFF");
  }
}

void reconnect() {
  while (!client.connected()) {
    if (client.connect("ESP32ClientNodeRED")) {
      client.subscribe(sub_topic);
    } else {
      delay(5000);
    }
  }
}

void setup() {
  pinMode(LED_PIN, OUTPUT);
  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
}
```

3. **Deploy Node-RED Flow:**
   1. Open Node-RED in browser (`http://localhost:1880` or device IP).
   2. Install Dashboard nodes: Menu → Manage Palette → Install `node-red-dashboard`.
   3. Drag an `inject` or `ui_button` node from Dashboard.
   4. Connect it to an `MQTT out` node configured to send to topic `lab7/ledcontrol`.
   5. Configure one button to send `"ON"` and another to send `"OFF"`.
   6. Deploy the flow.

4. **Open Dashboard:**
   - Visit `http://localhost:1880/ui` (or server IP) to control the LED.

## Expected Results
- The Node-RED Dashboard displays buttons for turning the LED ON/OFF.
- The ESP32 responds instantly to button presses by changing LED state.
- Serial Monitor logs incoming MQTT messages.

## Discussion Questions
1. How does Node-RED simplify IoT dashboard creation?
2. How could you extend the dashboard to display sensor readings?
3. What are the benefits of using MQTT as the backend protocol for Node-RED IoT dashboards?
4. How can authentication be implemented for the Node-RED Dashboard?

