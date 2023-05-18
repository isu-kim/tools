#!/bin/bash

# Ask input
if [ "$1" = "master" ]; then
	echo Master Node Setup
else
	echo Worker Node Setup
fi	

echo "Press any key to continue..."
read -n 1 -s
echo "Continuing with the script"

# Install Docker
if command -v docker &> /dev/null; then
	echo "Docker was installed"
else
	sudo curl -sSL https://get.docker.com/ | sh # Install Docker
	sudo gpasswd -a $USER docker # Enable docker without sudo
	sudo chmod 666 /var/run/docker.sock # Enable docker without sudo
fi

if command -v kubeadm &> /dev/null; then
	echo "Kubernetes as installed"
else
	# Add K8s Repo
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
	sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

	# Install Kubernetes (Docker)
	sudo apt-get install -y kubeadm=1.23.0-00 kubelet=1.23.0-00 kubectl=1.23.0-00
	sudo apt-mark hold kubeadm kubelet kubectl
fi

# Set firewall 
if [ "$1" = "master" ]; then
	sudo iptables -I INPUT 1 -p tcp --dport 6443 -j ACCEPT # kube API
	sudo iptables -I INPUT 1 -p tcp --dport 2370 -j ACCEPT # etcd
	sudo iptables -I INPUT 1 -p tcp --dport 2380 -j ACCEPT # etcd
	sudo iptables -I INPUT 1 -p tcp --dport 10250 -j ACCEPT # kubelet API
	sudo iptables -I INPUT 1 -p tcp --dport 10259 -j ACCEPT # kube-scheduler
	sudo iptables -I INPUT 1 -p tcp --dport 10257 -j ACCEPT # kube-controller-manager
	sudo iptables -I INPUT 1 -p tcp --dport 179 -j ACCEPT # calico
else
	sudo iptables -I INPUT 1 -p tcp --dport 10250 -j ACCEPT # kubelet
	sudo iptables -A INPUT -p tcp --match multiport --dports 30000:32767 -j ACCEPT # nodeport services
	sudo iptables -I INPUT 1 -p tcp --dport 179 -j ACCEPT # calico
fi

# Init Kubeadm
sudo swapoff -a  # Don't forget this! or kubelet will not run
sudo kubeadm reset
sudo rm -rf $HOME/.kube/config

if [ "$1" = "master" ]; then
	sudo kubeadm init --pod-network-cidr=10.0.0.0/16
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config
else
	echo Enter Join token from Master Node:
	read userInput
	eval "$userInput"
fi	

# Setup CNI
if [ "$1" = "master" ]; then
	# Install Calico and set it with CIDR 192.168.0.0/16
	wget https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml
	kubectl create -f tigera-operator.yaml
	wget https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml
	sed -i 's/192\.168\.0\.0\/16/10.0.0.0\/16/g' "custom-resources.yaml"
	kubectl create -f custom-resources.yaml
else
	echo Worker Node Setup
fi	
