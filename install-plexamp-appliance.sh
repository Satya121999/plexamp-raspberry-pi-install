#!/usr/bin/env bash
set -euo pipefail

USER_NAME="${SUDO_USER:-pi}"
HOSTNAME_DEFAULT="PlexPie"
PLEXAMP_DIR="/opt/plexamp"
KIOSK_PROFILE="/home/${USER_NAME}/.config/chromium-kiosk"
KIOSK_BIN_DIR="/home/${USER_NAME}/bin"

echo "Using user: ${USER_NAME}"

if ! id "${USER_NAME}" >/dev/null 2>&1; then
  echo "User ${USER_NAME} does not exist."
  exit 1
fi

read -rp "Hostname [${HOSTNAME_DEFAULT}]: " HOSTNAME_INPUT
HOSTNAME_INPUT="${HOSTNAME_INPUT:-$HOSTNAME_DEFAULT}"

echo "Updating system..."
apt update
apt full-upgrade -y

echo "Installing packages..."
apt install -y \
  curl \
  jq \
  chromium \
  unclutter \
  git \
  avahi-daemon \
  xserver-xorg \
  x11-xserver-utils \
  nodejs \
  npm

echo "Enabling avahi..."
systemctl enable --now avahi-daemon

echo "Setting hostname..."
hostnamectl set-hostname "${HOSTNAME_INPUT}"
echo "${HOSTNAME_INPUT}" > /etc/hostname

echo "Installing Plexamp..."
mkdir -p "${PLEXAMP_DIR}"
chown "${USER_NAME}:${USER_NAME}" "${PLEXAMP_DIR}"
sudo -u "${USER_NAME}" bash -c "
  cd '${PLEXAMP_DIR}'
  curl -L https://plexamp.plex.tv/headless/latest | tar -xJ --strip-components=1
"

echo "Creating Plexamp service..."
cat >/etc/systemd/system/plexamp.service <<EOF
[Unit]
Description=Plexamp
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=${USER_NAME}
Group=${USER_NAME}
Environment=HOME=/home/${USER_NAME}
WorkingDirectory=${PLEXAMP_DIR}
ExecStart=/usr/bin/node ${PLEXAMP_DIR}/js/index.js
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable plexamp

echo "Detecting USB DAC..."
DAC_CARD="$(aplay -l | awk -F'[: ]+' '/USB/ && !/HDMI/ {print $4; exit}')"

if [[ -n "${DAC_CARD}" ]]; then
  echo "Detected DAC card: ${DAC_CARD}"
  cat >/etc/asound.conf <<EOF
pcm.!default {
    type plug
    slave.pcm "plughw:${DAC_CARD},0"
}

ctl.!default {
    type hw
    card ${DAC_CARD}
}
EOF
else
  echo "No USB DAC detected right now. You can configure /etc/asound.conf later."
fi

echo "Creating kiosk scripts..."
mkdir -p "${KIOSK_BIN_DIR}"
chown -R "${USER_NAME}:${USER_NAME}" "${KIOSK_BIN_DIR}"
mkdir -p "${KIOSK_PROFILE}"
chown -R "${USER_NAME}:${USER_NAME}" "/home/${USER_NAME}/.config"

cat >"${KIOSK_BIN_DIR}/kiosk.sh" <<EOF
#!/bin/bash

until curl -s http://127.0.0.1:32500 > /dev/null; do
    sleep 0.5
done

exec chromium \\
  --kiosk \\
  --noerrdialogs \\
  --disable-infobars \\
  --disable-session-crashed-bubble \\
  --no-first-run \\
  --password-store=basic \\
  --use-mock-keychain \\
  --disable-gpu \\
  --user-data-dir=${KIOSK_PROFILE} \\
  http://127.0.0.1:32500
EOF

cat >"${KIOSK_BIN_DIR}/kiosk-watchdog.sh" <<EOF
#!/bin/bash
while true; do
  if ! curl -s --max-time 2 http://127.0.0.1:32500 > /dev/null; then
    pkill chromium || true
    ${KIOSK_BIN_DIR}/kiosk.sh &
  fi
  sleep 15
done
EOF

chmod +x "${KIOSK_BIN_DIR}/kiosk.sh" "${KIOSK_BIN_DIR}/kiosk-watchdog.sh"
chown "${USER_NAME}:${USER_NAME}" "${KIOSK_BIN_DIR}/kiosk.sh" "${KIOSK_BIN_DIR}/kiosk-watchdog.sh"

echo "Configuring LXDE autostart..."
mkdir -p "/home/${USER_NAME}/.config/lxsession/LXDE-pi"
cat >"/home/${USER_NAME}/.config/lxsession/LXDE-pi/autostart" <<EOF
@xset s off
@xset -dpms
@xset s noblank
@unclutter -idle 0
@${KIOSK_BIN_DIR}/kiosk.sh
@${KIOSK_BIN_DIR}/kiosk-watchdog.sh
EOF
chown -R "${USER_NAME}:${USER_NAME}" "/home/${USER_NAME}/.config/lxsession"

echo "Enabling desktop autologin..."
raspi-config nonint do_boot_behaviour B4

echo "Disabling USB autosuspend..."
CMDLINE_FILE="/boot/firmware/cmdline.txt"
if [[ -f "${CMDLINE_FILE}" ]]; then
  if ! grep -q "usbcore.autosuspend=-1" "${CMDLINE_FILE}"; then
    sed -i 's/$/ usbcore.autosuspend=-1/' "${CMDLINE_FILE}"
  fi
fi

echo "Starting Plexamp..."
systemctl restart plexamp

echo
echo "Install complete."
echo
echo "Next steps:"
echo "1. Reboot: sudo reboot"
echo "2. On first boot, Chromium will open Plexamp"
echo "3. Sign into Plex once in the kiosk UI"
echo "4. Your login will persist after that"
echo
echo "Access later via:"
echo "  ssh ${USER_NAME}@${HOSTNAME_INPUT}.local"
echo "  http://${HOSTNAME_INPUT}.local:32500"
