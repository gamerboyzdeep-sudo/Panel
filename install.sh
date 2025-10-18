#!/bin/bash
set -e

sudo su << 'EOF'

echo "[1/6] Updating system..."
apt update -y

echo "[2/6] Installing Docker & Docker Compose..."
apt install -y docker.io docker-compose wget

echo "[3/6] Creating docker directory..."
mkdir -p /dockercomp/win-data
cd /dockercomp

echo "[4/6] Creating Windows 10 Docker Compose file with Persistent Storage..."
cat << 'EOL' > Win10.yml
services:
  windows:
    image: dockurr/windows
    container_name: windows
    environment:
      VERSION: "10"
      USERNAME: "Zuzzyyuu"
      PASSWORD: "VlqL123"
      RAM_SIZE: "4G"
      CPU_CORES: "4"
      DISK_SIZE: "500G"
    devices:
      - /dev/kvm
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    ports:
      - 8006:8006
      - 3389:3389/tcp
      - 3389:3389/udp
    volumes:
      - ./win-data:/data   # ✅ Data save here
    stop_grace_period: 2m
EOL

echo "[5/6] Enabling auto-restart on reboot..."
cat << 'EOR' > /etc/systemd/system/windows-docker.service
[Unit]
Description=Windows 10 Docker Autostart
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=/dockercomp
ExecStart=/usr/bin/docker-compose -f Win10.yml up -d
ExecStop=/usr/bin/docker-compose -f Win10.yml down
Restart=always

[Install]
WantedBy=multi-user.target
EOR

systemctl enable windows-docker.service

echo "[6/6] Starting Windows 10 Docker..."
docker-compose -f Win10.yml up -d

EOF
