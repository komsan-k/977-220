# 🧩 Mosquitto MQTT Broker Setup and Configuration Guide

## ✅ 1. Installation

### On Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install mosquitto mosquitto-clients -y
sudo systemctl enable mosquitto
sudo systemctl start mosquitto
```

### On Windows
1. Download the `.msi` installer from [Eclipse Mosquitto](https://mosquitto.org/download/).
2. Run the installer and check **"Service"** so it runs in the background.
3. The broker listens on `localhost:1883` by default.

### On Docker
```bash
docker run -d --name mos1 -p 1883:1883   -v ~/mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf   eclipse-mosquitto:2
```

---

## 🛠️ 2. Configuration File (`mosquitto.conf`)

### Default Locations
- **Linux:** `/etc/mosquitto/mosquitto.conf`
- **Windows:** `C:\Program Files\mosquitto\mosquitto.conf`

### File Format
- Each line uses `keyword value` format.
- Lines starting with `#` are comments.
- To include extra configs:
  ```text
  include_dir /etc/mosquitto/conf.d
  ```

---

## 🔧 3. Key Configuration Settings for IoT

### Listener Configuration
```conf
listener 1883 0.0.0.0
protocol mqtt
```

### Authentication and Passwords
```conf
allow_anonymous false
password_file /etc/mosquitto/passwd
```
Create password file:
```bash
sudo mosquitto_passwd -c /etc/mosquitto/passwd esp32_a1
```

### Access Control Lists (ACL)
```conf
acl_file /etc/mosquitto/acl
```
Example ACL file:
```text
user esp32_a1
topic write v1/psu/thailand/phuket/esp32_a1/#
topic read  v1/psu/thailand/phuket/esp32_a1/#
```

### Persistence and Logging
```conf
persistence true
persistence_location /var/lib/mosquitto/
log_dest file /var/log/mosquitto/mosquitto.log
```

### TLS (Optional for Secure Connection)
```conf
listener 8883
protocol mqtt
cafile /etc/mosquitto/certs/ca.crt
certfile /etc/mosquitto/certs/server.crt
keyfile /etc/mosquitto/certs/server.key
require_certificate false
```

---

## 🧩 4. Example `mosquitto.conf` for ESP32 IoT Lab

```conf
# Mosquitto configuration for ESP32 IoT Lab
listener 1883 0.0.0.0
protocol mqtt

allow_anonymous false
password_file /etc/mosquitto/passwd
acl_file       /etc/mosquitto/acl

persistence true
persistence_location /var/lib/mosquitto/
log_dest file /var/log/mosquitto/mosquitto.log

include_dir /etc/mosquitto/conf.d
```

### Example `passwd` file
```
esp32_a1:<encrypted password>
esp32_b2:<encrypted password>
```

### Example `acl` file
```
user esp32_a1
topic write v1/psu/thailand/phuket/esp32_a1/#
topic read  v1/psu/thailand/phuket/esp32_a1/#

user esp32_b2
topic write v1/psu/thailand/phuket/esp32_b2/#
topic read  v1/psu/thailand/phuket/esp32_b2/#
```

---

## 🧪 5. Testing & Verification

### Using Mosquitto Clients
```bash
mosquitto_sub -h <broker_ip> -t v1/psu/# -u esp32_a1 -P <password>
mosquitto_pub -h <broker_ip> -t v1/psu/thailand/phuket/esp32_a1/temperature -m "25.4" -u esp32_a1 -P <password>
```

### View Logs
```bash
sudo tail -f /var/log/mosquitto/mosquitto.log
```

---

## ⚙️ 6. Large-Scale Deployment Tips

| Feature | Recommendation |
|----------|----------------|
| **Security** | Disable anonymous access, use TLS and ACLs. |
| **Scalability** | Use multiple brokers (cluster or bridge). |
| **Performance** | Use QoS 0/1 for telemetry; reserve QoS 2 for control. |
| **Persistence** | Enable persistence for reliable reconnects. |
| **Topic Design** | Use hierarchical naming (e.g., `v1/psu/thailand/phuket/esp32_a1/sensor_data`). |

---

## 🧠 Summary

- Mosquitto is a lightweight, open-source MQTT broker for IoT systems.  
- Configure **listener**, **authentication**, **ACL**, and **logging** for secure, scalable operation.  
- Perfect for ESP32-based IoT systems and Node-RED dashboards.
