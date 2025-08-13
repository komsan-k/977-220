# Lab 10: Integrating Wi-Fi, MQTT, and BLE in a Hybrid IoT Application

## Objective
- Combine Wi-Fi (MQTT) and Bluetooth Low Energy (BLE) communication in a single ESP32 program.
- Publish sensor data over MQTT to an IoT platform and simultaneously transmit via BLE to a local client.
- Demonstrate hybrid IoT communication strategies for flexibility and redundancy.

## Required Hardware and Software
- ESP32 development board.
- DHT22 temperature and humidity sensor (or equivalent).
- Breadboard and jumper wires.
- Computer with Arduino IDE.
- Local Wi-Fi network.
- MQTT broker (public or local Mosquitto).
- Node-RED or MQTT dashboard tool.
- Smartphone with BLE scanner app (e.g., nRF Connect, LightBlue).
- Arduino libraries:
  - `WiFi.h`
  - `PubSubClient`
  - `DHT sensor library` (Adafruit)
  - `Adafruit Unified Sensor`
  - `BLEDevice`, `BLEServer`, `BLEUtils`, `BLE2902`

## Background Theory
Hybrid IoT applications use multiple communication protocols to ensure:
- **Flexibility:** Devices can interact with both local BLE clients and remote MQTT servers.
- **Redundancy:** If one communication channel fails, the other can still deliver data.
- **Scalability:** BLE for nearby devices, MQTT for cloud services.

The ESP32’s dual-mode radio enables simultaneous BLE and Wi-Fi operation.

## Procedure
1. **Wire the DHT22 to ESP32** as described in Lab 3.
2. **Arduino Sketch:**
```cpp
#include <WiFi.h>
#include <PubSubClient.h>
#include "DHT.h"
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// Wi-Fi credentials
const char* ssid = "Your_SSID";
const char* password = "Your_PASSWORD";

// MQTT broker
const char* mqtt_server = "test.mosquitto.org";
const int mqtt_port = 1883;
const char* pub_topic = "lab10/sensordata";

// DHT sensor
#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

// BLE
#define SERVICE_UUID        "12345678-1234-1234-1234-1234567890ab"
#define CHARACTERISTIC_UUID "abcd1234-5678-90ab-cdef-1234567890ab"
BLECharacteristic* pCharacteristic;
bool deviceConnected = false;

// BLE Callbacks
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) { deviceConnected = true; }
  void onDisconnect(BLEServer* pServer) { deviceConnected = false; }
};

WiFiClient espClient;
PubSubClient client(espClient);

void setup_wifi() {
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");
}

void reconnect_mqtt() {
  while (!client.connected()) {
    if (client.connect("ESP32HybridClient")) {
      // Connected
    } else {
      delay(5000);
    }
  }
}

void setup_ble() {
  BLEDevice::init("ESP32_Hybrid_Sensor");
  BLEServer* pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());
  BLEService* pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ |
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
  pCharacteristic->addDescriptor(new BLE2902());
  pService->start();
  pServer->getAdvertising()->start();
}

void setup() {
  Serial.begin(115200);
  dht.begin();
  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
  setup_ble();
}

void loop() {
  if (!client.connected()) {
    reconnect_mqtt();
  }
  client.loop();

  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  if (!isnan(humidity) && !isnan(temperature)) {
    // JSON payload
    char payload[50];
    snprintf(payload, sizeof(payload),
             "{\"temperature\": %.2f, \"humidity\": %.2f}",
             temperature, humidity);

    // Publish via MQTT
    client.publish(pub_topic, payload);

    // Send via BLE
    if (deviceConnected) {
      pCharacteristic->setValue(payload);
      pCharacteristic->notify();
    }

    Serial.print("MQTT & BLE Sent: ");
    Serial.println(payload);
  }

  delay(5000);
}
```
3. **Upload the code** to the ESP32.
4. **On a smartphone:**
   - Open BLE scanner and connect to `ESP32_Hybrid_Sensor`.
   - View sensor data in the BLE characteristic.
5. **In Node-RED or MQTT client:**
   - Subscribe to `lab10/sensordata`.
   - Observe the same data arriving via MQTT.

## Expected Results
- The ESP32 transmits the same sensor readings over both BLE and MQTT.
- Local BLE devices and remote MQTT dashboards receive synchronized data.
- The Serial Monitor logs all transmissions.

## Discussion Questions
1. What are the main advantages of combining Wi-Fi (MQTT) and BLE in one IoT application?
2. How would you handle synchronization if BLE and MQTT messages have different transmission rates?
3. What power-saving strategies could be applied in this hybrid setup?
4. How can this architecture be extended to include additional communication protocols like LoRaWAN or Zigbee?

