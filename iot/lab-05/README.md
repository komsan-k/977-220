# Lab 5: Subscribing to MQTT Topics and Controlling Devices

## Objective
- Configure the ESP32 to subscribe to an MQTT topic.
- Receive messages from the broker and use them to control an LED.
- Understand two-way MQTT communication for IoT control applications.

## Required Hardware and Software
- ESP32 development board.
- Micro-USB cable.
- LED and 220 Ω resistor.
- Breadboard and jumper wires.
- Computer with Arduino IDE.
- Local Wi-Fi network.
- MQTT broker (public like `test.mosquitto.org` or local Mosquitto installation).
- MQTT client (e.g., MQTT Explorer, Node-RED, Mosquitto CLI).
- Arduino libraries:
  - `WiFi.h`
  - `PubSubClient`

## Background Theory
In MQTT, *subscribers* receive messages on specific topics published by other clients.  
By combining publishing and subscribing, IoT devices can perform bi-directional communication:
- **Publish:** Send data to the broker.
- **Subscribe:** Listen for commands from the broker.

In this lab, the ESP32 will subscribe to a topic, and incoming messages will control an LED.

## Procedure
1. **Wire the LED:**
   - LED anode (long leg) → GPIO 5 via 220 Ω resistor.
   - LED cathode (short leg) → GND.

2. **Arduino Sketch:**
```cpp
#include <WiFi.h>
#include <PubSubClient.h>

// Wi-Fi credentials
const char* ssid = "Your_SSID";
const char* password = "Your_PASSWORD";

// MQTT broker
const char* mqtt_server = "test.mosquitto.org";
const int mqtt_port = 1883;
const char* subscribe_topic = "lab5/ledcontrol";

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
      client.subscribe(subscribe_topic);
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

3. **Upload the code** to ESP32 and open Serial Monitor at 115200 baud.
4. **From an MQTT client,** publish `"ON"` or `"OFF"` to `lab5/ledcontrol`.
5. Observe the LED turning on and off according to messages received.

## Expected Results
- The ESP32 subscribes to the specified MQTT topic.
- Messages `"ON"` or `"OFF"` control the LED state.
- Serial Monitor displays topic, message content, and LED status.

## Discussion Questions
1. How does the `callback()` function process MQTT messages?
2. What would happen if you subscribe to multiple topics in the same client?
3. How can you modify the code to control multiple devices from different topics?
4. What security features should be considered for controlling devices over MQTT?

