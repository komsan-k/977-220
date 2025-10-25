This lab integrates Wi-Fi, MQTT communication, and PWM-based dimming control for an LED using the ESP32 platform.

🌐 Lab: MQTT-Based LED Control with ESP32 (Subscriber with Dimming Function)
🧩 1. Objective

The objective of this laboratory is to demonstrate MQTT-based device control through an ESP32 subscriber that receives commands to turn an LED on, off, or adjust brightness (0–100%) from an MQTT broker.

Students will learn to:

Configure ESP32 as an MQTT client and subscriber.

Implement Wi-Fi and MQTT connection routines.

Control PWM signals to vary LED brightness based on MQTT messages.

Test and visualize MQTT message control using Node-RED or HiveMQ web tools.

⚙️ 2. Background Theory
2.1 MQTT Communication

Message Queuing Telemetry Transport (MQTT) is a lightweight, publish–subscribe messaging protocol widely used in IoT.
It allows devices to publish data or subscribe to topics through a broker.

Key Terms:

Term	Description
Broker	Central server that manages message exchange.
Topic	String identifier for message channels.
Publisher	Sends data to a topic.
Subscriber	Receives messages from a topic.
2.2 ESP32 PWM Control

Pulse Width Modulation (PWM) allows control of analog-like output using digital signals.
The ESP32 provides multiple PWM channels controlled by the LED Control (LEDC) peripheral.
The duty cycle determines brightness (0–255 in 8-bit resolution).

Duty Cycle (%)
=
ON Time
Period
×
100
Duty Cycle (%)=
Period
ON Time
	​

×100
🔌 3. Components and Requirements
Component	Quantity	Description
ESP32 Dev Board	1	Any model (e.g., ESP32-WROOM-32)
LED	1	Any color
Resistor	1	220 Ω for LED
Breadboard & Jumper wires	—	For prototyping
MQTT Broker	1	broker.hivemq.com (public)
PC	1	Running Arduino IDE & MQTT dashboard (Node-RED / HiveMQ Web)
⚡ 4. Circuit Diagram

Connection Table:

ESP32 Pin	Component	Description
GPIO 12	LED anode (+)	PWM output
GND	LED cathode (-)	Common ground via 220 Ω resistor

Description:
The LED is connected to GPIO 12, configured as a PWM channel for dimming control.

💻 5. Program Code (ESP32 Subscriber with Dimming)
#include <WiFi.h>
#include <PubSubClient.h>

// ====== WiFi Configuration ======
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// ====== MQTT Configuration ======
const char* mqtt_server = "broker.hivemq.com";  // Public broker
const int mqtt_port = 1883;
const char* mqtt_topic = "esp32/led/control";   // Subscription topic

// ====== LED Configuration ======
const int LED_PIN = 12;
const int PWM_CHANNEL = 0;
const int PWM_FREQ = 5000;
const int PWM_RES = 8;

WiFiClient espClient;
PubSubClient client(espClient);

// ====== Wi-Fi Setup ======
void setup_wifi() {
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ WiFi connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

// ====== Callback ======
void callback(char* topic, byte* payload, unsigned int length) {
  String message;
  for (unsigned int i = 0; i < length; i++) message += (char)payload[i];
  message.trim();
  message.toLowerCase();

  Serial.print("📩 Message received: ");
  Serial.println(message);

  if (message == "on") {
    ledcWrite(PWM_CHANNEL, 255);
    Serial.println("💡 LED ON (100%)");
  } else if (message == "off") {
    ledcWrite(PWM_CHANNEL, 0);
    Serial.println("💤 LED OFF (0%)");
  } else {
    bool numeric = true;
    for (unsigned int i = 0; i < message.length(); i++)
      if (!isDigit(message[i])) numeric = false;

    if (numeric) {
      int percent = constrain(message.toInt(), 0, 100);
      int duty = map(percent, 0, 100, 0, 255);
      ledcWrite(PWM_CHANNEL, duty);
      Serial.printf("🔆 LED DIMMED to %d%% (Duty: %d)\n", percent, duty);
    } else {
      Serial.println("⚠️ Invalid command. Use 'on', 'off', or a number 0–100.");
    }
  }
}

// ====== Reconnect to MQTT ======
void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    if (client.connect("ESP32_LED_Subscriber")) {
      Serial.println("connected ✅");
      client.subscribe(mqtt_topic);
    } else {
      Serial.print("failed, rc=");
      Serial.println(client.state());
      delay(5000);
    }
  }
}

// ====== Setup ======
void setup() {
  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);

  ledcSetup(PWM_CHANNEL, PWM_FREQ, PWM_RES);
  ledcAttachPin(LED_PIN, PWM_CHANNEL);
  ledcWrite(PWM_CHANNEL, 0);
}

// ====== Loop ======
void loop() {
  if (!client.connected()) reconnect();
  client.loop();
}

🧠 6. Code Explanation
Section	Description
Wi-Fi Connection	Connects to specified SSID and obtains local IP address.
MQTT Setup	Configures MQTT broker and subscribes to topic "esp32/led/control".
Callback Function	Parses incoming messages and adjusts LED brightness.
PWM Initialization	Sets 5 kHz PWM frequency and 8-bit resolution for GPIO 12.
Message Parsing	Handles "on", "off", or numeric (0–100) inputs for dimming.
📟 7. Example Serial Monitor Output
Connecting to MyWiFiNetwork
.......
✅ WiFi connected!
IP address: 192.168.1.102
Attempting MQTT connection...connected ✅
📩 Message received: on
💡 LED ON (100%)
📩 Message received: 50
🔆 LED DIMMED to 50% (Duty: 128)
📩 Message received: off
💤 LED OFF (0%)

🌐 8. Testing with MQTT Dashboard
Option 1 — HiveMQ Web Client

Open: https://www.hivemq.com/demos/websocket-client/

Broker: broker.hivemq.com, Port 8000 (WebSocket)

Subscribe Topic: esp32/led/control

Publish messages:

on

off

25, 50, 75, 100

Option 2 — Node-RED Control Flow

Inject node → MQTT out → Debug node

Topic: esp32/led/control

Payload examples: on, off, or numeric slider (0–100)

🔬 9. Exercises

Basic Control:
Publish "on" and "off" commands and observe LED behavior.

PWM Dimming Test:
Send "25", "50", "75", and "100" messages and record LED brightness.

Custom Range:
Modify code to use 10-bit PWM resolution for smoother dimming.

Multi-Device Control:
Expand to control two LEDs on GPIO 12 and 14 with different topics.

Dashboard Integration:
Design a Node-RED dashboard slider for dynamic brightness adjustment.

🧾 10. Observation Table
Command	Received Payload	PWM Duty (0–255)	LED Brightness (%)
on	255	255	100
off	0	0	0
25	25	64	25
50	50	128	50
75	75	191	75
🧩 11. Discussion

This experiment demonstrates how IoT control systems can integrate MQTT communication with hardware-level PWM to achieve remote and dynamic lighting control. The same architecture can be extended for:

Smart home automation (light dimming, fan speed).

Industrial IoT dashboards.

Cloud-controlled actuators or motors.

The key insight is how payload-based interpretation enables flexible device behavior using a single topic.

📚 12. References

MQTT.org, “MQTT Version 3.1.1 Specification.”

Espressif Systems, “ESP32 Technical Reference Manual.”

HiveMQ, “WebSocket MQTT Client Demo.”

PubSubClient Library Documentation — https://pubsubclient.knolleary.net
