# Lab 4: Publishing Sensor Data via MQTT

## Objective
- Configure the ESP32 to connect to an MQTT broker over Wi-Fi.
- Publish real-time sensor data (temperature and humidity) to a specific MQTT topic.
- Understand the MQTT publish/subscribe model for IoT communication.

## Required Hardware and Software
- ESP32 development board.
- DHT22 temperature and humidity sensor (or equivalent).
- Breadboard, jumper wires, and 10 kΩ resistor (for pull-up).
- Computer with Arduino IDE.
- Local Wi-Fi network with Internet access.
- MQTT broker (public or local, e.g., Eclipse Mosquitto).
- MQTT client tool (e.g., MQTT Explorer, Mosquitto client tools, or Node-RED).
- Arduino libraries:
  - `DHT sensor library` (Adafruit)
  - `Adafruit Unified Sensor`
  - `PubSubClient` (Nick O’Leary)

## Background Theory
MQTT (Message Queuing Telemetry Transport) is a lightweight publish/subscribe messaging protocol designed for low-bandwidth, high-latency networks.

Key concepts:
- **Broker:** Central server managing message distribution.
- **Publisher:** Sends messages to a topic.
- **Subscriber:** Receives messages from a topic.

In this lab, the ESP32 will:
1. Connect to Wi-Fi.
2. Connect to an MQTT broker.
3. Read temperature and humidity from the DHT22 sensor.
4. Publish these readings to an MQTT topic.

## Procedure
1. **Wire the DHT22 to ESP32** as in Lab 3.
2. **Install Required Libraries:**
   - Open Arduino IDE → `Sketch` → `Include Library` → `Manage Libraries`.
   - Install `PubSubClient` by Nick O’Leary.
3. **Write the Arduino Sketch:**
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
const char* mqtt_topic = "lab4/sensordata";

// DHT settings
#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

// Wi-Fi and MQTT clients
WiFiClient espClient;
PubSubClient client(espClient);

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

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP32Client-" + String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
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

  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  char payload[50];
  snprintf(payload, sizeof(payload),
           "{"temperature": %.2f, "humidity": %.2f}",
           temperature, humidity);

  client.publish(mqtt_topic, payload);
  Serial.print("Published: ");
  Serial.println(payload);

  delay(5000);
}
```
4. **Upload Code** to ESP32 and open the Serial Monitor at 115200 baud.
5. **Verify Data in MQTT Client:** Subscribe to the topic `lab4/sensordata` and check incoming messages.

## Expected Results
- The ESP32 connects to Wi-Fi and the MQTT broker.
- The ESP32 publishes JSON-formatted sensor readings every 5 seconds.
- The MQTT client successfully receives and displays the data.

## Discussion Questions
1. Why is MQTT preferred over HTTP for many IoT applications?
2. What is the significance of the topic name in MQTT?
3. How would you modify the code to publish data only when values change significantly?
4. What security features can be added to make MQTT communication more secure?

