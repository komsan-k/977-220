// esp32_fpga_uart.ino
// ESP32 DevKit: TX2=GPIO17 -> FPGA RX, RX2=GPIO16 <- FPGA TX

#include <Arduino.h>

#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY(byte)    (byte & 0x80 ? '1' : '0'),    (byte & 0x40 ? '1' : '0'),    (byte & 0x20 ? '1' : '0'),    (byte & 0x10 ? '1' : '0'),    (byte & 0x08 ? '1' : '0'),    (byte & 0x04 ? '1' : '0'),    (byte & 0x02 ? '1' : '0'),    (byte & 0x01 ? '1' : '0')

static const uint32_t BAUD = 115200;

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("ESP32 <-> Nexys A7 UART demo");

  // Serial2: RX=16, TX=17
  Serial2.begin(BAUD, SERIAL_8N1, 16, 17);
}

uint8_t led_pat = 0x01;
unsigned long t_led = 0, t_poll = 0;

void send_set_led(uint8_t v) {
  uint8_t pkt[2] = { 0x55, v };
  Serial2.write(pkt, 2);
}

void request_switches() {
  uint8_t cmd = 0xAA;
  Serial2.write(&cmd, 1);
}

void loop() {
  unsigned long now = millis();

  // update LED pattern every 1000 ms
  if (now - t_led >= 1000) {
    t_led = now;
    send_set_led(led_pat);
    Serial.printf("Sent LED = 0x%02X\n", led_pat);
    led_pat = (led_pat << 1) ? (led_pat << 1) : 0x01;
    if (led_pat == 0) led_pat = 0x01;
  }

  // request switch state every 500 ms
  if (now - t_poll >= 500) {
    t_poll = now;
    request_switches();
  }

  // read responses: expect 'S' then one byte
  while (Serial2.available()) {
    int b = Serial2.read();
    if (b == 0x53) { // 'S'
      while (!Serial2.available()) { /* wait */ }
      int s = Serial2.read();
      Serial.printf("FPGA switches = 0b" BYTE_TO_BINARY_PATTERN "\n", BYTE_TO_BINARY(s));
    }
  }
}
