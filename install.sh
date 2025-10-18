#!/bin/bash
set -e

echo "==============================="
echo " Windows 10 Docker Setup Script"
echo "==============================="

# Step 1: Check storage
echo "[1/6] Checking disk space..."
df -h

# Step 2: Create Docker data folder
echo "[2/6] Creating Docker storage folder..."
sudo mkdir -p /tmp/docker-data

# Step 3: Configure Docker daemon
echo "[3/6] Configuring Docker to use new storage..."
sudo bash -c 'cat > /etc/docker/daemon.json' <<EOF
{
  "data-root": "/tmp/docker-data"
}
EOF

echo "Restarting Docker..."
sudo systemctl restart docker || true

# Step 4: Verify Docker
echo "[4/6] Docker info:"
docker info || { echo "Docker failed. Install Docker first!"; exit 1; }

# Step 5: Create windows10.yml
echo "[5/6] Creating windows10.yml..."
cat > windows10.yml <<EOF
services:
  windows:
    image: dockurr/windows
    container_name: windows
    environment:
      VERSION: "10"
      USERNAME: \${WINDOWS_USERNAME}
      PASSWORD: \${WINDOWS_PASSWORD}
      RAM_SIZE: "4G"
      CPU_CORES: "4"
    cap_add:
      - NET_ADMIN
    ports:
      - "8006:8006"
      - "3389:3389/tcp"
    volumes:
      - /tmp/docker-data:/mnt/disco1
      - windows-data:/mnt/windows-data
    devices:
      - "/dev/kvm:/dev/kvm"
      - "/dev/net/tun:/dev/net/tun"
    stop_grace_period: 2m
    restart: always

volumes:
  windows-data:
EOF

# Step 6: Create .env
echo "[6/6] Creating .env file..."
cat > .env <<EOF
WINDOWS_USERNAME=Admin
WINDOWS_PASSWORD=Deepak@123
EOF

echo "=================================="
echo "✅ Setup complete!"
echo "➡ Start Windows 10 using command:"
echo "docker-compose -f windows10.yml up -d"
echo "=================================="
