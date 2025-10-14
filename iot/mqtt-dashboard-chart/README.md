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

