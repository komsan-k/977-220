# 🧪 Lab Manuscript: Real-Time Temperature Line Chart via MQTT + Tkinter

## 1) Objective
Build a Python desktop dashboard that:
- Subscribes to an MQTT temperature topic.
- Plots a **live line chart** (Matplotlib in Tkinter).
- Computes rolling **min / max / average**.
- Uses a **thread-safe** queue between MQTT callbacks and the GUI loop.

---

## 2) Background Theory

### 2.1 MQTT (Publish/Subscribe)
- **Publisher** sends sensor readings to a **topic** (e.g., `test/sensor/temperature`).
- **Subscriber** listens to that topic and receives data asynchronously.
- A **Broker** (e.g., `broker.hivemq.com`) routes messages.

### 2.2 Real-Time Visualization in Tkinter
- **Tkinter** provides the GUI window, labels, and layout.
- **Matplotlib** renders the chart (embedded in Tk via `FigureCanvasTkAgg`).
- **Thread safety:** MQTT callbacks run in a network thread; we pass values to Tk using a **`SimpleQueue`** and update the chart on a Tk timer (`root.after`).

---

## 3) Materials & Setup

| Item | Details |
|---|---|
| Language | Python 3.x |
| Libraries | `paho-mqtt`, `matplotlib`, `tkinter` (bundled), `collections`, `queue` |
| Broker | `broker.hivemq.com` (public) |
| Topic | `test/sensor/temperature` |
| OS | Windows / macOS / Linux |

**Install:**
```bash
pip install paho-mqtt matplotlib
# (Linux only if needed)
sudo apt-get install python3-tk
```

---

## 4) Procedure

### Step A — (Optional) Start a Temperature Publisher
Use a separate terminal/script to publish numeric temperatures to the topic:
```python
import paho.mqtt.client as mqtt, time, random
client = mqtt.Client()
client.connect("broker.hivemq.com", 1883, 60)
while True:
    t = round(random.uniform(22.0, 30.0), 2)
    client.publish("test/sensor/temperature", t)
    time.sleep(2)
```

### Step B — Run the Subscriber Dashboard
Use the provided script (below) to subscribe and visualize.

---

## 5) Code: `mqtt_linechart_subscriber.py`
*(Full Python code provided in the lab section.)*

import tkinter as tk
from tkinter import ttk
import time
from collections import deque
from queue import SimpleQueue

import paho.mqtt.client as mqtt
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg

# --- MQTT Config ---
BROKER_ADDRESS = "broker.hivemq.com"
TOPIC = "test/sensor/temperature"   # must match your publisher

# --- Data/State ---
MAX_POINTS = 300            # keep last N points (~5 min if publisher=1s)
values = deque(maxlen=MAX_POINTS)
timestamps = deque(maxlen=MAX_POINTS)
updates = SimpleQueue()     # thread-safe handoff MQTT -> GUI

# ---------- Tkinter GUI ----------
root = tk.Tk()
root.title("MQTT Temperature — Live Line Chart")
root.geometry("820x560")

title = ttk.Label(root, text="Real-Time Temperature (MQTT)", font=("Arial", 14, "bold"))
title.pack(pady=(10, 4))

stats_label = ttk.Label(root, text="Min: --  Max: --  Avg: --", font=("Arial", 11))
stats_label.pack(pady=(0, 8))

# Matplotlib figure
fig, ax = plt.subplots(figsize=(8, 4))
line, = ax.plot([], [], lw=2)
ax.set_title("Temperature vs Time")
ax.set_xlabel("Samples (most recent on the right)")
ax.set_ylabel("Temperature (°C)")
ax.grid(True, alpha=0.3)

canvas = FigureCanvasTkAgg(fig, master=root)
canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

# ---------- Plot update ----------
def refresh_plot():
    """Pull the latest values from the queue, update data arrays and redraw chart."""
    # Drain the queue to get the newest reading
    latest = None
    try:
        while True:
            latest = updates.get_nowait()  # (t, value)
    except Exception:
        pass

    if latest is not None:
        t, v = latest
        timestamps.append(t)
        values.append(v)

        # Update line
        x = list(range(len(values)))  # simple sample index on x-axis
        line.set_data(x, list(values))
        if values:
            ax.set_xlim(0, max(10, len(values)-1))
            ymin = min(values)
            ymax = max(values)
            pad = max(0.5, (ymax - ymin) * 0.1)
            ax.set_ylim(ymin - pad, ymax + pad)

            # Stats
            avg = sum(values) / len(values)
            stats_label.config(text=f"Min: {ymin:.2f}  Max: {ymax:.2f}  Avg: {avg:.2f}")

        canvas.draw_idle()

    # Schedule again
    root.after(200, refresh_plot)  # ~5 Hz UI refresh

def on_close():
    try:
        client.loop_stop()
        client.disconnect()
    except Exception:
        pass
    root.destroy()

root.protocol("WM_DELETE_WINDOW", on_close)

# ---------- MQTT callbacks ----------
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print(f"✅ Connected successfully to MQTT broker with result code {rc}")
        client.subscribe(TOPIC)
        print(f"🔔 Subscribed to topic: {TOPIC}")
    else:
        print(f"❌ Connection failed with result code {rc}")

def on_message(client, userdata, msg):
    try:
        val = float(msg.payload.decode())
        updates.put((time.time(), val))  # pass timestamp + value to GUI thread
        # (Optional) print incoming data:
        # print(f"➡️ {val:.2f}°C [{msg.topic}]")
    except ValueError:
        print(f"Error: Received non-numeric data on {msg.topic}: {msg.payload.decode()}")

# ---------- MQTT setup (paho-mqtt 2.x safe) ----------
# Use legacy callback API v1 so current callback signatures work unchanged.
client = mqtt.Client(
    client_id="TkLineChartSubscriber",
    callback_api_version=mqtt.CallbackAPIVersion.VERSION1
)
client.on_connect = on_connect
client.on_message = on_message

print(f"Attempting to connect to {BROKER_ADDRESS}...")
client.connect(BROKER_ADDRESS, 1883, 60)
client.loop_start()

# Start GUI
root.after(200, refresh_plot)
root.mainloop()


---

## 6) Expected Results & Observations

- The window displays a **live line chart**; new points appear as messages arrive.
- The **stats label** updates continuously: `Min`, `Max`, `Avg`.
- The y-axis auto-scales with padding for readability.
- No GUI freezes: MQTT runs in its own loop; UI updates are scheduled by Tk.

---

## 7) Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| No updates on chart | Publisher not running / wrong topic | Verify the topic and publisher; try the sample publisher |
| ValueError on payload | Non-numeric payload | Ensure publisher sends numeric strings (e.g., `"25.7"`) |
| Tkinter import error | `tkinter` not installed (Linux) | `sudo apt-get install python3-tk` |
| Callback API error (paho-mqtt 2.x) | New callback API | Use `callback_api_version=mqtt.CallbackAPIVersion.VERSION1` (as in code) |

---

## 8) Extensions (Optional)
- **True timestamps on x-axis** (use `matplotlib.dates` and format time).
- **Threshold bands** (fill green/yellow/red regions to indicate safe/high temps).
- **CSV logging** (append `(timestamp, value)` to a file).
- **Multiple series** (e.g., temp + humidity) with a legend.
- **Alerting** (popup or color change when value > threshold).

---

## 9) Assessment (Quick Check)

1) Which function schedules periodic GUI updates?  
**Answer:** `root.after(…)`

2) Why use `SimpleQueue`?  
**Answer:** To safely pass data from the MQTT thread to the Tk main thread.

3) Where do we subscribe to the topic and why there?  
**Answer:** In `on_connect`; ensures re-subscription after reconnect.

4) What is `MAX_POINTS` used for?  
**Answer:** Limits history length (rolling buffer) to bound memory and keep chart responsive.

5) How would you adapt the chart to show humidity (0–100%)?  
**Answer:** Subscribe to a humidity topic, maintain a second deque and line, adjust labels/units.

---

## 10) References
- Eclipse Foundation, *MQTT v5.0 Specification*.  
- Matplotlib Docs — Embedding in Tk: `matplotlib.backends.backend_tkagg`.  
- Tkinter Docs: Python Standard Library.  
- HiveMQ Public Broker info page.

