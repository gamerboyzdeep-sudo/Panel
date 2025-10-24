#!/bin/bash
# Author: Your Name
# Description: Automatically install Docker and run Windows 10 container via docker-compose

# Stop on error
set -e

# Step 1: Update system packages
echo "Updating system packages..."
sudo apt update -y

# Step 2: Install Docker and docker-compose
echo "Installing Docker and docker-compose..."
sudo apt install -y docker.io docker-compose wget

# Step 3: Check Docker installation
echo "Checking Docker installation..."
docker --version
docker-compose --version

# Step 4: Create working directory
WORKDIR="$HOME/dockercomp"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# Step 5: Download docker-compose YAML file
echo "Downloading Win10VLqL.yml..."
wget -O Win10VLqL.yml https://raw.githubusercontent.com/VLqL069/Win10/7a57fa82a99c1cf3cfaeed17a629d0856061692e/Win10VLqL.yml

# Step 6: Display the YAML content
echo "Here is the docker-compose file content:"
cat Win10VLqL.yml

# Step 7: Run the container
echo "Starting Windows 10 container..."
sudo docker-compose -f Win10VLqL.yml up -d

echo "✅ Windows 10 container started successfully!"
