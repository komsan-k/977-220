# Lab 8: Displaying Sensor Data on Node-RED Dashboard

## Objective
- Configure ESP32 to publish temperature and humidity data to an MQTT broker.
- Use Node-RED Dashboard to visualize real-time sensor data.
- Understand how to integrate MQTT data streams with graphical widgets.

## Required Hardware and Software
- ESP32 development board.
- DHT22 temperature and humidity sensor (or equivalent).
- Breadboard and jumper wires.
- Computer with Arduino IDE.
- Local Wi-Fi network.
- MQTT broker (public or local Mosquitto).
- Node-RED installed on PC or Raspberry Pi.
- Node-RED Dashboard nodes (`node-red-dashboard`).
- Web browser for dashboard access.
- Arduino libraries:
  - `WiFi.h`
  - `PubSubClient`
  - `DHT sensor library` (Adafruit)
  - `Adafruit Unified Sensor`

## Background Theory
Node-RED Dashboard provides UI widgets (gauges, charts, text displays) that can subscribe to MQTT topics and show real-time values from IoT devices.  
In this lab:
1. ESP32 publishes sensor data in JSON format.
2. Node-RED subscribes to the topic and updates the dashboard.

## Procedure
1. **Wire the DHT22 to ESP32** as described in Lab 3.
2. **Arduino Sketch for ESP32:**
```cpp
#include <WiFi.h>
#include <PubSubClient.h>
#include "DHT.h"

// Wi-Fi credentials
const char* ssid = "Your_SSID";
const char* password = "Your_PASSWORD";

// MQTT broker
const char* mqtt_server = "test.mosquitto.org";
const int mqtt_port = 1883;
const char* pub_topic = "lab8/sensordata";

// DHT sensor settings
#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

WiFiClient espClient;
PubSubClient client(espClient);

void setup_wifi() {
  delay(10);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");
}

void reconnect() {
  while (!client.connected()) {
    if (client.connect("ESP32Publisher")) {
      // Connected
    } else {
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  dht.begin();
  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  if (!isnan(humidity) && !isnan(temperature)) {
    char payload[50];
    snprintf(payload, sizeof(payload),
             "{"temperature": %.2f, "humidity": %.2f}",
             temperature, humidity);
    client.publish(pub_topic, payload);
    Serial.print("Published: ");
    Serial.println(payload);
  }

  delay(5000);
}
```
3. **Create Node-RED Flow:**
   1. Open Node-RED (`http://localhost:1880` or device IP).
   2. Drag an `MQTT in` node and configure it to subscribe to `lab8/sensordata`.
   3. Use a `JSON` node to parse the incoming JSON data.
   4. Connect the parsed output to:
      - A `ui_gauge` node for temperature.
      - A `ui_gauge` node for humidity.
      - A `ui_chart` node to show data trends.
   5. Deploy the flow.
4. **Open Dashboard:**
   - Visit `http://localhost:1880/ui` (or server IP) to view live gauges and charts.

## Expected Results
- The ESP32 publishes JSON-formatted temperature and humidity data every 5 seconds.
- The Node-RED Dashboard displays real-time readings in gauges and charts.
- The dashboard updates automatically without refreshing the page.

## Discussion Questions
1. What is the advantage of sending JSON-formatted data over MQTT?
2. How could you add multiple sensors to the same MQTT topic?
3. How can Node-RED be used to trigger alerts when readings exceed thresholds?
4. How can you store this data for long-term analysis?

