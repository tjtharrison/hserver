#!/bin/bash

################
# Update system
################

sudo apt-get update
sudo apt-get upgrade -y

################
# Install docker and launch containers
################

# Check if docker exec exists
if ! command -v docker &> /dev/null; then
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
fi

################
# Install and configure NFS
################

# Check if nfs server is installed
if [[ ! -f /etc/exports ]]; then
    echo "Installing nfs server"
    sudo apt install nfs-kernel-server
else
    echo "NFS server already installed"
fi

# Check if nfs directory exists
if [[ ! -d /mnt/nfs ]]; then
    sudo mkdir -p /mnt/nfs
    sudo chmod 777 /mnt/nfs
fi

# Check if symbolic link exists
if [[ -f /etc/exports ]]; then
    sudo rm /etc/exports
fi

if [ -f ./conf/nfs-exports ]; then
    sudo ln -s $(pwd)/conf/nfs-exports /etc/exports
    sudo systemctl restart nfs-kernel-server
elif [ ../conf/nfs-exports ]; then
    sudo ln -s $(pwd)/../conf/nfs-exports /etc/exports
    sudo systemctl restart nfs-kernel-server
else
    echo "No exports file found"
    exit 1
fi

sudo service nfs-kernel-server restart
