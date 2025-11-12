#!/bin/bash

# Configuration variables
BACKUP_DIR="/minecraft/backups"
# Get most recent backup file using ls -t (sort by time) and head
LATEST_BACKUP=$(ls -t "$BACKUP_DIR" | head -n 1)

# Safety check: Ensure we have a backup before proceeding
if [ -z "$LATEST_BACKUP" ]; then
    echo "No backup found! Restore aborted."
    exit 1
fi

echo "Stopping server..."
sudo systemctl stop minecraft

echo "Restoring worlds, server.properties, and permissions.json from backup..."
cd /minecraft/bedrock
# Restore top-level configuration files and worlds directory, including permissions.json
tar -xzvf "$BACKUP_DIR/$LATEST_BACKUP" -C /minecraft/bedrock --strip-components=1 ./server.properties ./permissions.json ./worlds
# Restore legacy default permissions file location if present in the archive
tar -xzvf "$BACKUP_DIR/$LATEST_BACKUP" -C /minecraft/bedrock/config/default --strip-components=3 ./config/default/permissions.json 2>/dev/null || true

echo "Ensuring bedrock_server is executable..."
chmod +x /minecraft/bedrock/bedrock_server

echo "Starting server..."
sudo systemctl start minecraft

echo "Restore complete!"