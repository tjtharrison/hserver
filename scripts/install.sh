#!/bin/bash

################
# Update system
################

sudo apt-ge t update
sudo apt-get upgrade -y

################
# Install docker and launch containers
################

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

docker compose up -d

################
# Install and configure NFS
################

sudo apt install nfs-kernel-server

mkdir -p /mnt/nfs
chmod 777 /mnt/nfs

sudo echo "/mnt/nfs 192.168.0.220(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
sudo echo "/mnt/nfs 192.168.0.221(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
sudo echo "/mnt/nfs 192.168.0.222(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports
sudo echo "/mnt/nfs 192.168.0.223(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports

sudo systemctl restart nfs-kernel-server