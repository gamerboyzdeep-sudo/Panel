#!/bin/bash
set -e

sudo su << 'EOF'

echo "[1/5] Updating system..."
apt update -y

echo "[2/5] Installing Docker & Docker Compose..."
apt install -y docker.io docker-compose wget

echo "[3/5] Creating docker directory..."
mkdir -p /dockercomp
cd /dockercomp

echo "[4/5] Creating Windows 10 Docker Compose file..."
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
    stop_grace_period: 2m
EOL

echo "[5/5] Starting Windows 10 Docker..."
docker-compose -f Win10.yml up -d

EOF
``` ✅ Done – no questions, no interaction.
