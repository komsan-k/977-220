# Lab 6: Bi-Directional MQTT — ESP32 as Publisher and Subscriber

## Objective
- Configure the ESP32 to both publish sensor data and subscribe to control messages via MQTT.
- Enable two-way communication between the ESP32 and an MQTT broker.
- Integrate DHT22 sensor readings with LED control.

## Required Hardware and Software
- ESP32 development board.
- DHT22 temperature and humidity sensor (or equivalent).
- LED with 220Ω resistor.
- Breadboard and jumper wires.
- Computer with Arduino IDE.
- Local Wi-Fi network.
- MQTT broker (public or local Mosquitto).
- MQTT client (e.g., MQTT Explorer, Node-RED, Mosquitto CLI).
- Arduino libraries:
  - `WiFi.h`
  - `PubSubClient`
  - `DHT sensor library` (Adafruit)
  - `Adafruit Unified Sensor`

## Background Theory
By combining publishing and subscribing in a single program, the ESP32 can:
- Send data (publish) periodically to inform other devices or dashboards.
- Listen (subscribe) for control commands from users or automation systems.

This is a common IoT pattern for devices that must both sense and act.

## Procedure
1. **Wire the DHT22 and LED:**
   - DHT22 connections same as Lab 3.
   - LED anode → GPIO 5 via 220Ω resistor; cathode → GND.

2. **Arduino Sketch:**
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
const char* pub_topic = "lab6/sensordata";
const char* sub_topic = "lab6/ledcontrol";

// DHT sensor
#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

// LED pin
#define LED_PIN 5

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

void callback(char* topic, byte* message, unsigned int length) {
  Serial.print("Message arrived on topic: ");
  Serial.println(topic);
  String messageTemp;

  for (int i = 0; i < length; i++) {
    messageTemp += (char)message[i];
  }
  Serial.println("Message: " + messageTemp);

  if (messageTemp == "ON") {
    digitalWrite(LED_PIN, HIGH);
    Serial.println("LED ON");
  } else if (messageTemp == "OFF") {
    digitalWrite(LED_PIN, LOW);
    Serial.println("LED OFF");
  }
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    String clientId = "ESP32Client-" + String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
      client.subscribe(sub_topic);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void setup() {
  pinMode(LED_PIN, OUTPUT);
  Serial.begin(115200);
  dht.begin();
  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  // Publish sensor data every 5 seconds
  static unsigned long lastPublish = 0;
  if (millis() - lastPublish > 5000) {
    float humidity = dht.readHumidity();
    float temperature = dht.readTemperature();

    if (!isnan(humidity) && !isnan(temperature)) {
      char payload[50];
      snprintf(payload, sizeof(payload),
               "{\"temperature\": %.2f, \"humidity\": %.2f}",
               temperature, humidity);
      client.publish(pub_topic, payload);
      Serial.print("Published: ");
      Serial.println(payload);
    } else {
      Serial.println("Failed to read from DHT sensor!");
    }
    lastPublish = millis();
  }
}
```

3. **Upload code** and open Serial Monitor at 115200 baud.
4. **In your MQTT client:**
   - Subscribe to `lab6/sensordata` to view sensor readings.
   - Publish `"ON"` or `"OFF"` to `lab6/ledcontrol` to control LED.

## Expected Results
- The ESP32 publishes sensor data every 5 seconds.
- The ESP32 responds to MQTT messages by controlling the LED.
- Serial Monitor logs both outgoing and incoming MQTT messages.

## Discussion Questions
1. How does combining publisher and subscriber logic improve IoT device capabilities?
2. What challenges could arise when scaling this setup to many devices?
3. How can Quality of Service (QoS) settings in MQTT improve reliability?
4. How could you modify this setup to control more than one actuator?

