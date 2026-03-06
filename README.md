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
- USB DAC (tested with SMSL D1 (usb c)
- HDMI display (optional) - tested with a $35 dollar screen from Amazon.

---

Here is a single install script that sets up:
	•	Raspberry Pi OS 64-bit
	•	Plexamp backend
	•	systemd service
	•	USB DAC default output
	•	Chromium kiosk
	•	persistent Plex login
	•	desktop autologin
	•	kiosk watchdog
	•	Avahi .local
	•	USB autosuspend disabled

What this script does not do automatically
  It does not do the Plex claim/login step, because that still needs your Plex account session once on first launch.
  So after reboot:
    	1.	Plexamp opens in kiosk
    	2.	You sign into Plex once
    	3.	It stays signed in because Chromium uses a persistent profile

Best install order
  On a fresh Pi:
    	1.	Plug in USB DAC first
    	2.	Boot Pi OS 64-bit
    	3.	Run the script
    	4.	Reboot
    	5.	Sign into Plex once


Instructions for the Pi:
 
