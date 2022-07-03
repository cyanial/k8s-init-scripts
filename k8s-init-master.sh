#!/bin/bash

# Enable iptables Bridged Traffic
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# Disable swap on all the Nodes
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
## You can also, control swap errors using the kubeadm parameter 
## --ignore-preflight-errors Swap

# Install Kubeadm & Kubelet & Kubectl on all Nodes (阿里云镜像)
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | sudo apt-key add - 
echo "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


# Start k8s master 

# IPADDR="10.0.0.10"
IPADDR="192.168.31.128"
NODENAME=$(hostname -s)

sudo kubeadm init \
--apiserver-advertise-address=$IPADDR \
--apiserver-cert-extra-sans=$IPADDR \
--pod-network-cidr=192.168.0.0/16 \
--node-name=$NODENAME \
--image-repository="registry.cn-hangzhou.aliyuncs.com/google_containers"
# --control-plane-endpoint= \ for upgrade control-plane
# --ignore-preflight-errors Swap


