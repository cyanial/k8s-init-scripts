#!/bin/bash

# Uninstall old verisons (optional)
sudo apt-get remove docker docker-engine docker.io containered runc

# Install using the repository
## Set up the repository
sudo apt-get update
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

## Add Docker's official GPG key:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

## Set up the repository:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine:
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Allow non-privileged users to run Docker commands:
## Create the docker group:
sudo groupapp docker

## Add your user to the docker group:
sudo usermod -aG docker $USER

## Add the docker daemon configurations to use systemd as the cgroup driver.
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": ["https://docker.mirrors.sjtug.sjtu.edu.cn"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

## Change the daemon.json to add image-register

## Start and enable the docker service.
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# Remove disabled_plugins of containerd
# /etc/containerd/config.toml