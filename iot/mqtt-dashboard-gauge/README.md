# 🧪 Lab Manuscript: IoT Temperature Gauge Dashboard using MQTT and Tkinter

## 1. Objective
The purpose of this laboratory exercise is to **develop a real-time IoT dashboard** using Python that:
- Subscribes to live sensor data (e.g., temperature) over MQTT.  
- Displays this data dynamically on an **analog-style gauge interface** using Tkinter and Matplotlib.  
- Demonstrates integration of **IoT communication protocols**, **data visualization**, and **thread-safe GUI updates**.

This lab combines **IoT networking**, **data visualization**, and **real-time application development**.

---

## 2. Theory: MQTT and Data Visualization

### 2.1 MQTT Protocol Overview
**MQTT (Message Queuing Telemetry Transport)** is a lightweight, publish–subscribe messaging protocol designed for small sensors and mobile devices with constrained bandwidth.

- **Publisher**: Sends data (e.g., sensor temperature) to a topic.  
- **Subscriber**: Listens to that topic and receives updates.  
- **Broker**: Manages message distribution between publishers and subscribers.

In this lab, the **Publisher** periodically publishes simulated temperature readings to a topic  
(e.g., `test/sensor/temperature`), while the **Subscriber** (our Tkinter dashboard) listens to that topic and visualizes the data in real time.

### 2.2 Visualization with Tkinter and Matplotlib
- **Tkinter**: Provides the GUI framework (window, labels, layout).  
- **Matplotlib (Polar Plot)**: Used to draw a semicircular analog gauge.  
- **Queue**: Ensures thread-safe data transfer between the MQTT callback and the Tkinter main loop.

This integration forms the core of **IoT Human–Machine Interfaces (HMI)** for monitoring smart environments.

---

## 3. Materials and Setup

| Component | Description |
|------------|-------------|
| Programming Language | Python 3.x |
| Libraries | `paho-mqtt`, `tkinter`, `matplotlib`, `numpy` |
| MQTT Broker | `broker.hivemq.com` (Public Broker) |
| Topic | `test/sensor/temperature` |
| Operating System | Windows / macOS / Linux |

### 3.1 Installation Commands
Install the required Python libraries:
```bash
pip install paho-mqtt matplotlib
```

Tkinter is pre-installed with Python on most systems.  
If missing, install it manually (Linux example):
```bash
sudo apt-get install python3-tk
```

---

## 4. Procedure

### Step 1: Setup the MQTT Broker
Use a **public broker** like `broker.hivemq.com`.  
<!--
Optionally, test using an MQTT publisher (e.g., a Python script or Node-RED flow) that sends random temperature data:

```python
# Example Publisher (optional)
import paho.mqtt.client as mqtt, time, random
client = mqtt.Client()
client.connect("broker.hivemq.com", 1883, 60)
while True:
    temperature = round(random.uniform(20, 30), 2)
    client.publish("test/sensor/temperature", temperature)
    print("Published:", temperature)
    time.sleep(3)
```

-->
---

### Step 2: Write the Subscriber (Dashboard)

**Filename:** `mqtt_gauge_subscriber.py`

```python
import tkinter as tk
from tkinter import ttk
import paho.mqtt.client as mqtt
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import numpy as np
from queue import SimpleQueue

# --- MQTT Configuration ---
BROKER_ADDRESS = "broker.hivemq.com"
TOPIC = "test/sensor/temperature"

# --- Shared state ---
updates = SimpleQueue()   # thread-safe queue for new data

# ---------- Gauge Drawing ----------
MIN_VAL, MAX_VAL = 0.0, 50.0   # °C scale

def draw_gauge(ax, value):
    v = max(MIN_VAL, min(MAX_VAL, value))
    ax.clear()
    ax.set_theta_offset(np.pi / 2)
    ax.set_theta_direction(-1)
    ax.set_ylim(0, 1)
    ax.axis("off")

    # Semicircle arc
    angles = np.linspace(-np.pi/2, np.pi/2, 200)
    ax.plot(angles, np.ones_like(angles)*0.9, color="lightgray", lw=16)

    # Ticks (every 10°C)
    for t in np.linspace(MIN_VAL, MAX_VAL, 6):
        frac = (t - MIN_VAL) / (MAX_VAL - MIN_VAL)
        ang  = np.pi * (1 - frac) - np.pi/2
        ax.plot([ang, ang], [0.8, 0.92], color="black", lw=2)
        ax.text(ang, 0.72, f"{t:.0f}", ha="center", va="center", fontsize=9)

    # Needle
    frac = (v - MIN_VAL) / (MAX_VAL - MIN_VAL + 1e-12)
    ang  = np.pi * (1 - frac) - np.pi/2
    ax.plot([ang, ang], [0.0, 0.9], color="red", lw=3)

    ax.set_title("Temperature Gauge (°C)", fontsize=12, pad=20)

# ---------- Tkinter GUI ----------
root = tk.Tk()
root.title("MQTT Temperature Gauge")
root.geometry("520x520")

ttk.Label(root, text="Real-Time Temperature (MQTT)",
          font=("Arial", 14, "bold")).pack(pady=8)
value_label = ttk.Label(root, text="--.- °C", font=("Arial", 16))
value_label.pack(pady=8)

fig, ax = plt.subplots(subplot_kw={"projection": "polar"})
canvas = FigureCanvasTkAgg(fig, master=root)
canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True, padx=8, pady=8)
draw_gauge(ax, MIN_VAL)
canvas.draw()

def apply_update():
    """Check for new data and refresh the gauge."""
    try:
        latest = None
        while True:
            latest = updates.get_nowait()
    except Exception:
        pass
    if latest is not None:
        value_label.config(text=f"{latest:.2f} °C")
        draw_gauge(ax, latest)
        canvas.draw()
    root.after(100, apply_update)

def on_close():
    try:
        client.loop_stop()
        client.disconnect()
    except Exception:
        pass
    root.destroy()

root.protocol("WM_DELETE_WINDOW", on_close)

# ---------- MQTT Callbacks ----------
def on_connect(client, userdata, flags, rc):
    print(f"Connected with result code: {rc}")
    if rc == 0:
        client.subscribe(TOPIC)
        print(f"Subscribed to: {TOPIC}")

def on_message(client, userdata, msg):
    try:
        temperature = float(msg.payload.decode())
        updates.put(temperature)
    except Exception:
        pass

# ---------- MQTT Setup ----------
client = mqtt.Client(
    client_id="TkGaugeSubscriber",
    callback_api_version=mqtt.CallbackAPIVersion.VERSION1
)
client.on_connect = on_connect
client.on_message = on_message
client.connect(BROKER_ADDRESS, 1883, 60)
client.loop_start()

# Start GUI Loop
root.after(100, apply_update)
root.mainloop()


```

---

## 5. Results and Observations

### Expected Output
- A GUI window appears with a **semicircular temperature gauge**.  
- As the publisher sends temperature readings, the needle moves accordingly.  
- The numerical display updates dynamically.

| Component | Observation |
|------------|--------------|
| MQTT Connection | Successful connection to `broker.hivemq.com` |
| Topic Subscription | Subscribed to `test/sensor/temperature` |
| Real-time Update | Gauge needle responds to new readings within ~0.1 sec |
| Thread Safety | Tkinter updates occur smoothly without blocking |

---

## 6. Discussion

This lab demonstrates:
- **MQTT interoperability** with Python GUIs.  
- **Thread-safe data visualization** using `SimpleQueue` to isolate network I/O from the UI thread.  
- **Polar coordinate plotting** to simulate analog instrumentation.  
- A scalable foundation for **IoT dashboards** that can be extended with:
  - Multiple gauges (e.g., humidity, CO₂)
  - Warning zones (color-coded arcs)
  - Database or cloud logging

---

## 7. Conclusion

The experiment successfully implemented a **real-time IoT dashboard** using MQTT and Tkinter, displaying live sensor data on a gauge interface.  
This project demonstrates the **integration of IoT communication, GUI programming, and data visualization**, fundamental to modern smart applications.

---

## 8. Exercises
1. Modify the gauge to display humidity (0–100%) with blue color.  
2. Add a digital thermometer widget showing the average temperature.  
3. Combine multiple MQTT topics (temperature, humidity, light) into one dashboard.  
4. Create color zones (green/yellow/red) to indicate safe and high temperature levels.  
5. Extend the dashboard to log temperature values into a CSV file.

---

## 9. References
- Eclipse Foundation, *MQTT Specification v5.0*, 2019.  
- Matplotlib Documentation: [https://matplotlib.org](https://matplotlib.org)  
- Tkinter GUI Guide: [https://docs.python.org/3/library/tkinter.html](https://docs.python.org/3/library/tkinter.html)  
- HiveMQ Public Broker: [https://www.hivemq.com/public-mqtt-broker/](https://www.hivemq.com/public-mqtt-broker/)

