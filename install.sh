#!/bin/bash
set -euo pipefail

# ------------------------------------------------------------------
# SIMPLE & FAST: Choose 1 of 3 Windows containers and start it
# - Single prompt only (choose 1/2/3/4)
# - No further questions/answers
# - Auto-installs Docker if missing (Debian/Ubuntu compatible)
# - Starts only the selected Windows VM (not all at once)
# - Big "MADE BY DEEPAK" banner on start
# NOTE: real Windows boot time depends on server resources and image
#       and can take a few minutes. This script will start the container
#       immediately but first boot may require time.
# ------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Large banner
clear
echo -e "${CYAN}${BOLD}"
echo "###############################################################"
echo "#                                                             #"
echo "#                      MADE BY DEEPAK                         #"
echo "#                                                             #"
echo "###############################################################"
echo -e "${NC}"
sleep 1

# Menu (single prompt)
cat <<'MENU'
Select Windows to install & start (choose 1 number - no further prompts):
  1) Windows 10  (fast start)
  2) Windows 11  (fast start)
  3) Windows 7   (fast start)
  4) Exit (Bye — Made by Deepak)
MENU

read -r -p "Enter choice [1-4]: " CHOICE

# Map selection to version, ports and credentials (no further prompts)
case "${CHOICE}" in
  1)
    VERSION="10"
    NAME="win10"
    WEB_PORT="8007"
    RDP_PORT="3390"
    USERNAME="Deepak"
    PASSWORD="Deepak@10"
    ;;
  2)
    VERSION="11"
    NAME="win11"
    WEB_PORT="8006"
    RDP_PORT="3389"
    USERNAME="Deepak"
    PASSWORD="Deepak@11"
    ;;
  3)
    VERSION="7"
    NAME="win7"
    WEB_PORT="8008"
    RDP_PORT="3391"
    USERNAME="Deepak"
    PASSWORD="Deepak@7"
    ;;
  4)
    echo -e "${YELLOW}Bye — Made by Deepak${NC}"
    exit 0
    ;;
  *)
    echo -e "${RED}Invalid choice. Exiting.${NC}"
    exit 1
    ;;
esac

echo -e "${CYAN}Selected: Windows ${VERSION} -> container name: ${NAME}${NC}"

# Ensure Docker present (minimal, for Debian/Ubuntu)
if ! command -v docker &>/dev/null; then
  echo -e "${CYAN}Docker not found. Installing Docker (non-interactive)...${NC}"
  # installer will exit non-zero on unsupported OS - that's expected
  curl -fsSL https://get.docker.com | sh
  # enable service if systemd present
  if command -v systemctl &>/dev/null; then
    systemctl enable --now docker || true
  fi
fi

# Create storage volume / folder
echo -e "${CYAN}Creating storage for ${NAME}...${NC}"
mkdir -p "${NAME}-data" >/dev/null 2>&1 || true

# Pull image (best-effort)
echo -e "${CYAN}Pulling dockurr/windows image (best-effort)...${NC}"
docker pull dockurr/windows || echo -e "${YELLOW}[!] docker pull failed or was interrupted, continuing (image may download while starting)${NC}"

# Stop & remove any existing container with same name
if docker ps -a --format '{{.Names}}' | grep -Eq "^${NAME}\$"; then
  echo -e "${CYAN}Removing existing container ${NAME}...${NC}"
  docker rm -f "${NAME}" >/dev/null 2>&1 || true
fi

# Start selected container (no prompts)
echo -e "${CYAN}Starting Windows ${VERSION} container (${NAME}) — fast start settings applied...${NC}"
docker run -d --name "${NAME}" --restart always \
  -p "${WEB_PORT}:${WEB_PORT}" -p "${RDP_PORT}:${RDP_PORT}" \
  -e VERSION="${VERSION}" \
  -e USERNAME="${USERNAME}" \
  -e PASSWORD="${PASSWORD}" \
  -e RAM_SIZE="4G" \
  -e CPU_CORES="2" \
  -v "${PWD}/${NAME}-data":/data \
  --cap-add NET_ADMIN \
  --device /dev/kvm:/dev/kvm \
  dockurr/windows >/dev/null

# Attempt to make Codespaces ports public if gh CLI available
if command -v gh &>/dev/null; then
  CSNAME="${CODESPACE_NAME:-${GITHUB_CODESPACE_NAME:-}}"
  if [ -n "${CSNAME}" ]; then
    gh codespace ports visibility "${RDP_PORT}:public" -c "${CSNAME}" >/dev/null 2>&1 || true
    gh codespace ports visibility "${WEB_PORT}:public" -c "${CSNAME}" >/dev/null 2>&1 || true
  fi
fi

# Final messages
echo
echo -e "${GREEN}✅ Done — Windows ${VERSION} container started.${NC}"
echo "=============================================================="
echo -e "${BOLD}MADE BY DEEPAK${NC}"
echo "--------------------------------------------------------------"
echo "Container name : ${NAME}"
echo "Web UI         : http://YOUR_SERVER_IP:${WEB_PORT}"
echo "RDP            : YOUR_SERVER_IP:${RDP_PORT}"
echo "Username       : ${USERNAME}"
echo "Password       : ${PASSWORD}"
echo "--------------------------------------------------------------"
echo -e "${YELLOW}Note: First boot may take a few minutes depending on your VPS resources.${NC}"
echo -e "${CYAN}After a short wait, connect via RDP using the username/password above.${NC}"
echo "=============================================================="

exit 0
