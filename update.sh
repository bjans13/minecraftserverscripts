#!/bin/bash

# Configuration variables
BACKUP_DIR="/minecraft/backups"
LATEST_BACKUP=$(ls -t "$BACKUP_DIR" | head -n 1)

# Safety check: Ensure we have a backup before proceeding
if [ -z "$LATEST_BACKUP" ]; then
    echo "No backup found! Update aborted."
    exit 1
fi

# Read latest download URL from updatecheck
# This file should be created by the update check process
LATEST_LINK_FILE="/minecraft/bedrock_last_link.txt"
if [ ! -f "$LATEST_LINK_FILE" ]; then
    echo "Latest version link not found! Update aborted."
    exit 1
fi

DOWNLOAD_URL=$(cat "$LATEST_LINK_FILE")

echo "Stopping server..."
sudo systemctl stop minecraft

echo "Backing up server..."
sudo /minecraft/backup.sh

echo "Downloading latest version..."
cd /minecraft/bedrock
wget --no-check-certificate --user-agent="Mozilla/5.0" -O bedrock-server.zip "$DOWNLOAD_URL"
if [ $? -ne 0 ]; then
    echo "Download failed! Update aborted."
    exit 1
fi

echo "Extracting new files..."
unzip -o bedrock-server.zip
rm bedrock-server.zip

echo "Ensuring bedrock_server is executable..."
chmod +x /minecraft/bedrock/bedrock_server

echo "Update complete!"

echo "Restoring settings and worlds..."
sudo bash /minecraft/restore.sh
if [ $? -ne 0 ]; then
    echo "Restoration failed! Please check manually."
    exit 1
fi