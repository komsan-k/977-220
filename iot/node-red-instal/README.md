# 🧰 Node-RED Installation Guide

This guide provides a step-by-step process to **install Node-RED locally** on your computer using **npm (Node Package Manager)**.

> 🧠 **Note:** Node-RED is built on **Node.js**, so you must install Node.js first.

---

## ⚙️ Step 1: Install Node.js and npm

### 1.1 Download Node.js
1. Visit the official Node.js website:  
   👉 [https://nodejs.org](https://nodejs.org)
2. Download the **LTS (Long-Term Support)** version — recommended for stability.
3. Run the installer and follow the default on-screen instructions.

### 1.2 Verify Installation
After installation, open your **Command Prompt** (Windows) or **Terminal** (macOS/Linux) and run:

```bash
node -v
npm -v
```

If version numbers are displayed, Node.js and npm have been installed successfully. ✅

---

## 🚀 Step 2: Install Node-RED

Once Node.js and npm are set up, you can install Node-RED as a global module.

### 2.1 Open Terminal or Command Prompt
Launch your command-line interface.

### 2.2 Run the Installation Command
Execute the following command:

```bash
npm install -g --unsafe-perm node-red
```

This installs Node-RED globally (`-g`) and uses the `--unsafe-perm` flag to avoid permission issues.

### 2.3 Operating System Notes
**For macOS/Linux:**
```bash
sudo npm install -g --unsafe-perm node-red
```

**For Windows:**
- If you encounter permission errors, **run Command Prompt as Administrator** before executing the installation command.

---

## 🌐 Step 3: Run and Access Node-RED

### 3.1 Start Node-RED
In your terminal, type:

```bash
node-red
```

You’ll see logs indicating that Node-RED is starting.  
When ready, it will show a message similar to:

```
Server now running at http://127.0.0.1:1880/
```

### 3.2 Access the Node-RED Editor
1. Open your preferred web browser (Chrome, Firefox, etc.).
2. Navigate to:  
   👉 [http://localhost:1880](http://localhost:1880)

You should now see the **Node-RED Flow Editor**, where you can start creating and deploying low-code automation flows. 🎛️

### 3.3 Stop Node-RED
To stop the Node-RED server, go back to the terminal and press:

```
Ctrl + C
```

---

## 🧩 Summary

| Task | Command | Description |
|------|----------|-------------|
| Check Node.js version | `node -v` | Verify Node.js installation |
| Check npm version | `npm -v` | Verify npm installation |
| Install Node-RED | `npm install -g --unsafe-perm node-red` | Global installation |
| Run Node-RED | `node-red` | Launch Node-RED editor |
| Access Node-RED | [http://localhost:1880](http://localhost:1880) | Open in web browser |

---

## 📚 References
- Official Node-RED: [https://nodered.org](https://nodered.org)  
- Node.js Download: [https://nodejs.org](https://nodejs.org)  
- npm Documentation: [https://docs.npmjs.com](https://docs.npmjs.com)
