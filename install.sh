#!/bin/bash
set -e

echo "[1/5] Installing Docker..."
if ! command -v docker &>/dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
fi

echo "[2/5] Pulling Windows base image..."
docker pull dockurr/windows

echo "[3/5] Creating storage..."
mkdir -p win11-data win10-data win7-data

echo "[4/5] Starting Windows Machines..."

# ---- Windows 11 ----
docker run -d --name win11 --restart always \
  -p 8006:8006 -p 3389:3389 \
  -e VERSION=11 \
  -e USERNAME=user11 \
  -e PASSWORD=pass11 \
  -v win11-data:/data \
  --cap-add NET_ADMIN \
  --device /dev/kvm \
  dockurr/windows

# ---- Windows 10 ----
docker run -d --name win10 --restart always \
  -p 8007:8007 -p 3390:3390 \
  -e VERSION=10 \
  -e USERNAME=user10 \
  -e PASSWORD=pass10 \
  -v win10-data:/data \
  --cap-add NET_ADMIN \
  --device /dev/kvm \
  dockurr/windows

# ---- Windows 7 ----
docker run -d --name win7 --restart always \
  -p 8008:8008 -p 3391:3391 \
  -e VERSION=7 \
  -e USERNAME=user7 \
  -e PASSWORD=pass7 \
  -v win7-data:/data \
  --cap-add NET_ADMIN \
  --device /dev/kvm \
  dockurr/windows

echo ""
echo "✅ Windows setup completed!"
echo "--------------------------------------------"
echo " Windows 11  → WEB: http://IP:8006 | RDP: IP:3389"
echo " Username: user11 | Password: pass11"
echo "--------------------------------------------"
echo " Windows 10  → WEB: http://IP:8007 | RDP: IP:3390"
echo " Username: user10 | Password: pass10"
echo "--------------------------------------------"
echo " Windows 7   → WEB: http://IP:8008 | RDP: IP:3391"
echo " Username: user7 | Password: pass7"
echo "--------------------------------------------"
echo "⚠ First boot may take 3–5 minutes..."
