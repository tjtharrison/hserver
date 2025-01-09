#!/bin/bash

# Create backup dir if it doesn't exist
backup_dir="/mnt/backup"
source_dir="/mnt/nfs"

# Generate list of dirs with exclude patterns
dirs=$(find $source_dir -maxdepth 1 -mindepth 1 -type d -not -name "archive*" -not -name "*db-storage*" -not -name "*loki*" -not -name "*prometheus*" -not -name "*grafana*")

# Create backup dir if it doesn't exist
if [ ! -d $backup_dir ]; then
  mkdir $backup_dir
fi

# Backup each dir
for dir in $dirs; do
  dir_name=$(basename $dir)
  today_date=$(date +%F)
  sudo tar -czf $backup_dir/$today_date-$dir_name.tar.gz $dir
done

# Remove old backups
# find $backup_dir -type f -mtime +30 -exec rm {} \;

# Copy backup to NAS
rsync -avh /mnt/backup hnas:/data/server-backups/hserver