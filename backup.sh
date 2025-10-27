#!/bin/bash

# Configuration variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/minecraft/backups"
WORLD_DIR="/minecraft/bedrock/worlds"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Create backup archive
# --exclude prevents recursive backup of previous backups
# -c: create archive, -z: compress with gzip, -v: verbose, -f: specify filename
tar --exclude="/minecraft/backups" -czvf "$BACKUP_DIR/minecraft_backup_$TIMESTAMP.tar.gz" -C /minecraft/bedrock .

echo "Backup completed: $BACKUP_DIR/minecraft_backup_$TIMESTAMP.tar.gz"

# Cleanup old backups
# Keep only the last 30 days of backups using find command
# -mtime +30: files modified more than 30 days ago
# -delete: remove matching files
find "$BACKUP_DIR" -type f -name "minecraft_backup_*.tar.gz" -mtime +30 -delete