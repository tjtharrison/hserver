#!/bin/bash

# Create backup dir if it doesn't exist
mkdir /mnt/backup

# Generate list of dirs
dirs=$(find /mnt/nfs/ -maxdepth 1 -mindepth 1 -type d -not -name "archive*" -not -name "*db-storage*" -not -name "*loki*" -not -name "*prometheus*" -not -name "*grafana*")

# Backup each dir
for dir in $dirs; do
  dir_name=$(basename $dir)
  tar -czf /mnt/backup/$dir_name.tar.gz $dir
done

# Remove old backups
find /mnt/backup/ -type f -mtime +30 -exec rm {} \;

# Copy backup to NAS
rsync -avh /mnt/backup root@192.168.0.200:/data/server-backups/hserver