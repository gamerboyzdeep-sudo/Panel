#!/bin/bash
set -e

# ---------------------------
# PRO Installer by Deepak
# Menu: Win10 | Win11 | Win7 | macOS | Info
# ---------------------------

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Big DEEPAK banner (ASCII)
print_banner(){
cat <<'BANNER'

██████╗ ███████╗██████╗  █████╗  █████╗ ██╗  ██╗
██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝
██████╔╝█████╗  ██████╔╝███████║███████║█████╔╝ 
██╔══██╗██╔══╝  ██╔══██╗██╔══██║██╔══██║██╔═██╗ 
██║  ██║███████╗██║  ██║██║  ██║██║  ██║██║  ██╗
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
BANNER
}

# Print red Info block
print_info(){
  echo -e "${RED}${BOLD}"
  echo "========================================"
  echo " MADE BY DEEPAK"
  echo " DO NOT COPY THIS CODE TO YOUTUBE OR ANYWHERE"
  echo " IF YOU RUN THIS BASH SCRIPT, BIG 'DEEPAK' WILL SHOW"
  echo "========================================"
  echo -e "${NC}"
}

# Ensure gh is available for Codespace port public (if inside codespace)
ensure_gh(){
  if ! command -v gh >/dev/null 2>&1; then
    echo -e "${YELLOW}Warning: gh CLI not found. Port-public steps will be skipped.${NC}"
    return 1
  fi
  return 0
}

# Make docker data directory and daemon.json
prepare_docker_storage(){
  echo -e "${CYAN}[+] Creating Docker storage folder: /tmp/docker-data${NC}"
  sudo mkdir -p /tmp/docker-data
  echo -e "${CYAN}[+] Writing /etc/docker/daemon.json${NC}"
  sudo bash -c 'cat > /etc/docker/daemon.json' <<'EOF'
{
  "data-root": "/tmp/docker-data"
}
EOF
  echo -e "${CYAN}[+] Restarting docker (may fail if systemd not available)${NC}"
  sudo systemctl restart docker || true
}

# Create .env with provided username/password
create_env(){
  local user="$1"
  local pass="$2"
  cat > .env <<EOF
WINDOWS_USERNAME=${user}
WINDOWS_PASSWORD=${pass}
EOF
  echo -e "${GREEN}[+] .env created${NC}"
}

# Create different YAML templates
create_yaml_windows(){
  local filename="$1"
  local version="$2"
  cat > "${filename}" <<EOF
services:
  windows:
    image: dockurr/windows
    container_name: windows
    environment:
      VERSION: "${version}"
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
  echo -e "${GREEN}[+] ${filename} created for Windows ${version}${NC}"
}

create_yaml_macos(){
  local filename="$1"
  # NOTE: Replace image with preferred macOS image if needed
  cat > "${filename}" <<EOF
services:
  macos:
    image: sickcodes/docker-osx:latest
    container_name: macos
    environment:
      PASSWORD: \${WINDOWS_PASSWORD}
    ports:
      - "5900:5900"   # VNC
      - "8006:8006"   # optional web ui
    volumes:
      - /tmp/docker-data:/mnt/disco1
    restart: always
EOF
  echo -e "${GREEN}[+] ${filename} created for macOS (image: sickcodes/docker-osx)${NC}"
}

# Make ports public in Codespace (if possible)
make_ports_public(){
  local csname="$CODESPACE_NAME"
  if [ -n "${csname}" ] && command -v gh >/dev/null 2>&1; then
    echo -e "${CYAN}[+] Making ports 3389 and 8006 public via gh codespace...${NC}"
    gh codespace ports visibility 3389:public -c "${csname}" || true
    gh codespace ports visibility 8006:public -c "${csname}" || true
    # if macOS, also make 5900 public
    gh codespace ports visibility 5900:public -c "${csname}" || true
    echo -e "${GREEN}[+] Ports set to public (if in Codespace)${NC}"
  else
    echo -e "${YELLOW}⚠ Not in Codespace or gh missing: skipping auto port-public.${NC}"
  fi
}

# Start the requested compose file
start_compose(){
  local file="$1"
  if command -v docker-compose >/dev/null 2>&1; then
    docker-compose -f "${file}" up -d
  elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    docker compose -f "${file}" up -d
  else
    echo -e "${RED}Docker Compose not found. Please install docker-compose or use 'docker compose'.${NC}"
    return 1
  fi
  echo -e "${GREEN}[+] Started compose: ${file}${NC}"
}

# Menu
while true; do
  clear
  print_banner
  echo
  echo -e "${BOLD}Select an option:${NC}"
  echo "  1) Install Windows 10 (default Windows setup)"
  echo "  2) Install Windows 11 (edit Windows YAML -> VERSION 11)"
  echo "  3) Install Windows 7 (edit Windows YAML -> VERSION 7)"
  echo "  4) Add MacBook (macOS) (edit Windows YAML -> macOS image)"
  echo "  5) Info / Credits"
  echo "  6) Exit"
  echo
  read -p "Enter choice [1-6]: " CHOICE

  case "${CHOICE}" in
    1)
      echo -e "${CYAN}You chose: Windows 10${NC}"
      # gather credentials
      read -p "Enter Windows username (default: Admin): " WUSER
      WUSER=${WUSER:-Admin}
      read -s -p "Enter Windows password (default: Deepak@123): " WPASS
      echo
      WPASS=${WPASS:-Deepak@123}
      prepare_docker_storage
      create_env "${WUSER}" "${WPASS}"
      create_yaml_windows "windows10.yml" "10"
      make_ports_public
      read -p "Start container now? (y/N): " STARTNOW
      if [[ "${STARTNOW,,}" == "y" ]]; then
        start_compose "windows10.yml"
      else
        echo -e "${YELLOW}You can start later with: docker-compose -f windows10.yml up -d${NC}"
      fi
      read -p "Press Enter to return to menu..."
      ;;
    2)
      echo -e "${CYAN}You chose: Windows 11${NC}"
      read -p "Enter Windows username (default: Admin): " WUSER
      WUSER=${WUSER:-Admin}
      read -s -p "Enter Windows password (default: Deepak@123): " WPASS
      echo
      WPASS=${WPASS:-Deepak@123}
      prepare_docker_storage
      create_env "${WUSER}" "${WPASS}"
      create_yaml_windows "windows11.yml" "11"
      make_ports_public
      read -p "Start container now? (y/N): " STARTNOW
      if [[ "${STARTNOW,,}" == "y" ]]; then
        start_compose "windows11.yml"
      else
        echo -e "${YELLOW}You can start later with: docker-compose -f windows11.yml up -d${NC}"
      fi
      read -p "Press Enter to return to menu..."
      ;;
    3)
      echo -e "${CYAN}You chose: Windows 7${NC}"
      read -p "Enter Windows username (default: Admin): " WUSER
      WUSER=${WUSER:-Admin}
      read -s -p "Enter Windows password (default: Deepak@123): " WPASS
      echo
      WPASS=${WPASS:-Deepak@123}
      prepare_docker_storage
      create_env "${WUSER}" "${WPASS}"
      create_yaml_windows "windows7.yml" "7"
      make_ports_public
      read -p "Start container now? (y/N): " STARTNOW
      if [[ "${STARTNOW,,}" == "y" ]]; then
        start_compose "windows7.yml"
      else
        echo -e "${YELLOW}You can start later with: docker-compose -f windows7.yml up -d${NC}"
      fi
      read -p "Press Enter to return to menu..."
      ;;
    4)
      echo -e "${CYAN}You chose: MacBook / macOS (experimental)${NC}"
      read -p "Enter VNC password (default: Deepak@123): " WPASS
      WPASS=${WPASS:-Deepak@123}
      prepare_docker_storage
      # For macOS we still use .env for password
      create_env "macuser" "${WPASS}"
      create_yaml_macos "macos.yml"
      make_ports_public
      read -p "Start macOS container now? (y/N): " STARTNOW
      if [[ "${STARTNOW,,}" == "y" ]]; then
        start_compose "macos.yml"
      else
        echo -e "${YELLOW}You can start later with: docker-compose -f macos.yml up -d${NC}"
      fi
      read -p "Press Enter to return to menu..."
      ;;
    5)
      clear
      print_banner
      echo
      # Red big info text
      echo -e "${RED}${BOLD}"
      echo "========================================"
      echo " MADE BY DEEPAK"
      echo " DO NOT COPY THIS CODE TO YOUTUBE OR ANYWHERE"
      echo " IF YOU RUN THIS BASH SCRIPT, BIG 'DEEPAK' WILL SHOW"
      echo "========================================"
      echo -e "${NC}"
      echo
      echo -e "${CYAN}Available YAML files created by this script if you chose installs:${NC}"
      echo " - windows10.yml"
      echo " - windows11.yml"
      echo " - windows7.yml"
      echo " - macos.yml"
      echo
      read -p "Press Enter to return to menu..."
      ;;
    6)
      echo -e "${GREEN}Goodbye!${NC}"
      exit 0
      ;;
    *)
      echo -e "${YELLOW}Invalid option. Try again.${NC}"
      sleep 1
      ;;
  esac
done
