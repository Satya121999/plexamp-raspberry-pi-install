# plexamp-raspberry-pi-install
Full Plexamp installation on Raspberry Pi with Raspberry Pi OS 64-bit desktop and kiosk mode.


# Plexamp Raspberry Pi Appliance

Turn a Raspberry Pi into a dedicated Plexamp music streamer.

Features:

- Raspberry Pi OS 64-bit
- Plexamp backend
- Chromium kiosk interface
- USB DAC support
- Automatic Plex login persistence
- Auto-restart watchdog
- Appliance-style boot
- Control from phone/tablet

Boot flow:

Pi Boot  
→ Plexamp service starts  
→ Chromium kiosk launches  
→ Plexamp UI appears  

Compatible hardware:

- Raspberry Pi 4 / 5
- USB DAC (tested with SMSL)
- HDMI display (optional)

---

## Installation

Flash Raspberry Pi OS (64-bit).

Then run:
git clone https://github.com/YOURNAME/plexamp-pi-appliance.git
cd plexamp-pi-appliance
chmod +x install.sh
sudo ./install.sh

Reboot after install.

---

## First Launch

After reboot:

1. Plexamp will open automatically
2. Sign into Plex once
3. Choose your music library

The session will persist for future boots.

---

## Access

SSH into your pi using ssh@<username>@<hostname.local>

Plexamp UI: 
http://<hostname of your pi>.local:32500

---

## Hardware Tested

- Raspberry Pi 4
- SMSL USB DAC
- Raspberry Pi 7" display
- Ethernet + WiFi

---

## Optional Features

- Screen sleep/wake automation
- DAC auto-detection
- Static network configuration

See `/docs`.

