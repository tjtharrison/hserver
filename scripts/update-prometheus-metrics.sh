#!/bin/bash

# If directory /tmp/node_exporter/ does not exist, create it
if [ ! -d /tmp/node_exporter/ ]; then
  mkdir /tmp/node_exporter/
  # Set the permissions of the directory to 777
  chmod 777 /tmp/node_exporter/
fi

# Read the output from /usr/lib/update-notifier/apt-check --human-readable splitting the string into two vars split by semicolon
IFS=';' read -r updates security <<< $(/usr/lib/update-notifier/apt-check 2>&1)

# Write the output to a file
echo "tjth_node_exporter_updates_total{type=\"updates\"} $updates" > /tmp/node_exporter/updates.prom
echo "tjth_node_exporter_updates_total{type=\"security\"} $security" >> /tmp/node_exporter/updates.prom

# Check if reboot required
if [ -f /var/run/reboot-required ]; then
  echo "tjth_node_exporter_reboot_required 1" >> /tmp/node_exporter/updates.prom
else
  echo "tjth_node_exporter_reboot_required 0" >> /tmp/node_exporter/updates.prom
fi