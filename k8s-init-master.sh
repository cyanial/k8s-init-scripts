#!/bin/bash

# Enable iptables Bridged Traffic
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
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

IPADDR="10.128.0.1"
NODENAME=$(hostname -s)

sudo kubeadm init \
--apiserver-advertise-address=$IPADDR \
--pod-network-cidr=192.168.0.0/16 \
--service-cidr=10.0.0.0/24 \
--node-name=$NODENAME \
--image-repository="registry.cn-hangzhou.aliyuncs.com/google_containers"
# --cri-socket="unix:///var/run/containerd/containerd.sock"
# --control-plane-endpoint= \ for upgrade control-plane
# --ignore-preflight-errors Swap



# Your Kubernetes control-plane has initialized successfully!

# To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Alternatively, if you are the root user, you can run:

#   export KUBECONFIG=/etc/kubernetes/admin.conf

# You should now deploy a pod network to the cluster.
# Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#   https://kubernetes.io/docs/concepts/cluster-administration/addons/

# Then you can join any number of worker nodes by running the following on each as root:

# kubeadm join 10.128.0.1:6443 --token u3q6v8.wekalw9903szck1t \
# 	--discovery-token-ca-cert-hash sha256:e44e8d19bed8a02e94307e1e7d1d06231554f68288e1f637378b6828f910a9b0