#!/bin/bash

# Mark unsuccessful until completion
echo "tjth_backup_status{hostname=\"$HOSTNAME\"} 0" >> /tmp/node_exporter/backup.prom

# Create backup dir if it doesn't exist
backup_dir="/mnt/backup"
source_dir="/mnt/nfs"

# Generate list of dirs with exclude patterns
dirs=$(find $source_dir -maxdepth 1 -mindepth 1 -type d -not -name "archive*" -not -name "*db-storage*" -not -name "*loki*" -not -name "*prometheus*" -not -name "*grafana*" -not -name "*consul*")

# Create backup dir if it doesn't exist
if [ ! -d $backup_dir ]; then
  mkdir $backup_dir
fi

# Backup each dir
for dir in $dirs; do
  echo "Backing up $dir.."
  dir_name=$(basename $dir)
  today_date=$(date +%F)
  sudo tar -czf $backup_dir/$today_date-$dir_name.tar.gz $dir
  echo "Backup of $dir done"
done

# Remove old backups
# find $backup_dir -type f -mtime +30 -exec rm {} \;

# Copy backup to NAS
echo "Copying backup to NAS.."
rsync -avh /mnt/backup hnas:/data/server-backups/$HOSTNAME
echo "Mischief managed!"
echo "tjth_backup_status{hostname=\"$HOSTNAME\"} 1" >> /tmp/node_exporter/backup.prom