# Lab 9: Using ESP32 with Bluetooth Low Energy (BLE) to Send Sensor Data

## Objective
- Configure the ESP32 as a Bluetooth Low Energy (BLE) server.
- Transmit temperature and humidity sensor data via BLE.
- Understand BLE GATT (Generic Attribute Profile) services and characteristics.

## Required Hardware and Software
- ESP32 development board.
- DHT22 temperature and humidity sensor (or equivalent).
- Breadboard and jumper wires.
- Arduino IDE with ESP32 board support.
- `DHT sensor library` (Adafruit) and `Adafruit Unified Sensor`.
- Smartphone with BLE scanner app (e.g., nRF Connect, LightBlue).

## Background Theory
Bluetooth Low Energy (BLE) is a wireless communication protocol designed for low-power IoT devices.

The BLE communication model consists of:
- **Server:** Hosts data as GATT services and characteristics.
- **Client:** Connects to the server and reads or subscribes to characteristic updates.

In this lab, the ESP32 acts as a BLE server and sends sensor readings to a smartphone client.

## Procedure
1. **Wire the DHT22 to ESP32** as described in Lab 3.
2. **Arduino Sketch:**
```cpp
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include "DHT.h"

#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;

bool deviceConnected = false;
#define SERVICE_UUID "12345678-1234-1234-1234-1234567890ab"
#define CHARACTERISTIC_UUID "abcd1234-5678-90ab-cdef-1234567890ab"

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
  }
  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
  }
};

void setup() {
  Serial.begin(115200);
  dht.begin();

  BLEDevice::init("ESP32_BLE_Sensor");
  pServer = BLEDevice::createServer();
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
  Serial.println("Waiting for a client connection...");
}

void loop() {
  if (deviceConnected) {
    float humidity = dht.readHumidity();
    float temperature = dht.readTemperature();
    if (!isnan(humidity) && !isnan(temperature)) {
      char buffer[50];
      snprintf(buffer, sizeof(buffer),
               "{\"temperature\": %.2f, \"humidity\": %.2f}",
               temperature, humidity);
      pCharacteristic->setValue(buffer);
      pCharacteristic->notify();
      Serial.print("Sent via BLE: ");
      Serial.println(buffer);
    }
    delay(5000);
  }
}
```
3. **Upload the code** to the ESP32.
4. **On a smartphone:**
   - Open nRF Connect or LightBlue.
   - Scan for `ESP32_BLE_Sensor`.
   - Connect and view the service/characteristic values.

## Expected Results
- The ESP32 advertises itself as a BLE device.
- Upon connecting with a BLE scanner app, sensor data appears every 5 seconds.
- The data format matches the JSON string sent from the ESP32.

## Discussion Questions
1. What is the role of the GATT service and characteristic in BLE communication?
2. How could this setup be modified to send multiple types of sensor data?
3. How does BLE compare to MQTT over Wi-Fi in terms of range and power consumption?
4. What security measures can be implemented in BLE communications?

