# Lab 3: Reading Sensor Data from ESP32

## Objective
- Interface the ESP32 with a DHT22 temperature and humidity sensor.
- Acquire and display real-time sensor readings on the Serial Monitor.
- Understand the use of external sensor libraries in Arduino IDE.

## Required Hardware and Software
- ESP32 development board.
- DHT22 temperature and humidity sensor (AM2302).
- 10 kΩ resistor (for pull-up).
- Breadboard and jumper wires.
- Arduino IDE with ESP32 board support.
- `DHT sensor library` and `Adafruit Unified Sensor` library (installable via Library Manager).

## Background Theory
The DHT22 is a digital-output sensor capable of measuring temperature and relative humidity. It communicates with the microcontroller using a proprietary single-wire protocol, requiring precise timing for data acquisition.  
A 10 kΩ pull-up resistor between the data pin and VCC ensures reliable signal transmission.

The `DHT.h` library simplifies:
- Initializing the sensor.
- Reading temperature and humidity values.
- Handling timing and communication details.

## Procedure
1. **Connect the DHT22 to the ESP32:**
   - Pin 1 (VCC) → 3.3V on ESP32.
   - Pin 2 (Data) → GPIO 4 on ESP32.
   - Pin 4 (GND) → GND on ESP32.
   - Place a 10 kΩ resistor between VCC and Data pin.

2. **Install the DHT Library:**
   1. Open Arduino IDE.
   2. Go to `Sketch` → `Include Library` → `Manage Libraries`.
   3. Search for "DHT sensor library" by Adafruit and install it (also install "Adafruit Unified Sensor").

3. **Write the Arduino Sketch:**
   ```cpp
   #include "DHT.h"

   #define DHTPIN 4      // GPIO4
   #define DHTTYPE DHT22 // Sensor type

   DHT dht(DHTPIN, DHTTYPE);

   void setup() {
     Serial.begin(115200);
     dht.begin();
   }

   void loop() {
     float humidity = dht.readHumidity();
     float temperature = dht.readTemperature();

     if (isnan(humidity) || isnan(temperature)) {
       Serial.println("Failed to read from DHT sensor!");
       return;
     }

     Serial.print("Humidity: ");
     Serial.print(humidity);
     Serial.print(" %	");
     Serial.print("Temperature: ");
     Serial.print(temperature);
     Serial.println(" *C");

     delay(2000);
   }
   ```

4. **Upload the Code:** Connect ESP32 and upload using Arduino IDE.

5. **View Output:** Open Serial Monitor at 115200 baud to observe readings every 2 seconds.

## Expected Results
- The Serial Monitor displays real-time temperature and humidity readings.
- Data updates occur approximately every 2 seconds.
- If the sensor is disconnected, an error message is displayed.

## Discussion Questions
1. Why is a pull-up resistor necessary on the DHT22 data line?
2. What could cause `NaN` (Not a Number) readings from the sensor?
3. How would you modify the code to output readings in Fahrenheit?
4. How could you log these readings for long-term analysis?

