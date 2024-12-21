#!/bin/bash

# Create backup dir if it doesn't exist
sudo mkdir /mnt/backup

# Generate list of dirs
exclude_patterns=("archive*" "*db-storage*" "*loki*" "*prometheus*" "*grafana*")
exclude_args=("${exclude_patterns[@]/#/-not -name }")
echo "find /mnt/nfs/ -maxdepth 1 -mindepth 1 -type d "${exclude_args[@]}""
dirs=$(find /mnt/nfs/ -maxdepth 1 -mindepth 1 -type d "${exclude_args[@]}")

# Backup each dir
for dir in $dirs; do
  dir_name=$(basename $dir)
  today_date=$(date +%F)
  sudo tar -czf /mnt/backup/$today_date_$dir_name.tar.gz $dir
done

# Remove old backups
find /mnt/backup/ -type f -mtime +30 -exec rm {} \;

# Copy backup to NAS
rsync -avh /mnt/backup root@192.168.0.200:/data/server-backups/hserver