#!/bin/bash
sudo kubeadm reset
sudo systemctl stop kubelet
sudo systemctl stop docker

sudo rm -rf $HOME/.kube
sudo rm -rf /etc/cni
sudo rm -rf /var/lib/cni
sudo rm -rf /var/lib/etcd
sudo rm -rf /var/lib/kubelet/*

sudo systemctl start docker
sudo systemctl start kubelet
