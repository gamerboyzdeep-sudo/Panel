#!/bin/bash

# ============================================
#  💻  Windows 10 Docker Setup Script
#  🔧  Made by: DEEPAK
# ============================================

# Function to display banner
show_banner() {
    clear
    echo "============================================"
    echo -e "\e[1;36m        🚀  MADE BY: \e[1;33mDEEPAK\e[0m"
    echo "============================================"
    echo ""
    echo "Choose an option:"
    echo "1) Start / Install Windows 10 container"
    echo "2) Stop Windows 10 container"
    echo ""
}

# Function to install and run Windows 10 container
start_install() {
    echo "Updating system packages..."
    sudo apt update -y

    echo "Installing Docker and Docker Compose..."
    sudo apt install -y docker.io docker-compose

    echo "Starting Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker

    DIR="dockercomp"
    if [ ! -d "$DIR" ]; then
        echo "Creating directory $DIR..."
        mkdir "$DIR"
    fi
    cd "$DIR" || exit

    YAML_FILE="windows10.yml"
    echo "Creating docker-compose file $YAML_FILE..."

    cat > "$YAML_FILE" <<EOL
services:
  windows:
    image: dockurr/windows
    container_name: windows
    environment:
      VERSION: "10"
      USERNAME: "MASTER"
      PASSWORD: "admin@123"
      RAM_SIZE: "4G"
      CPU_CORES: "4"
      DISK_SIZE: "400G"
      DISK2_SIZE: "100G"
    devices:
      - /dev/kvm
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    ports:
      - "8006:8006"
      - "3389:3389/tcp"
      - "3389:3389/udp"
    stop_grace_period: 2m
EOL

    echo "Launching Windows 10 container..."
    sudo docker-compose -f "$YAML_FILE" up -d

    echo "✅ Done! Container 'windows' should now be running."
}

# Function to stop the container
stop_container() {
    echo "Stopping Windows 10 container..."
    sudo docker stop windows && sudo docker rm windows
    echo "🛑 Container 'windows' stopped and removed."
}

# Main menu
show_banner
read -rp "Enter your choice [1 or 2]: " choice

case $choice in
    1)
        start_install
        ;;
    2)
        stop_container
        ;;
    *)
        echo "Invalid choice. Exiting."
        ;;
esac
