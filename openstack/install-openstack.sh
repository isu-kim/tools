#!/bin/bash

# Install OpenStack using Packstack
# This will only work on CentOS (min 8 Stream)
# The original commands came from: https://www.rdoproject.org/install/packstack/

# 1. Set Network settings
sudo dnf install network-scripts -y

sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo systemctl disable NetworkManager
sudo systemctl stop NetworkManager
sudo systemctl enable network
sudo systemctl start network

# 2. Add Repositories and install OpenStack Yoga
sudo dnf config-manager --enable powertools
sudo dnf install -y centos-release-openstack-yoga
sudo dnf update -y

# 3. Install PackStack
sudo dnf install -y openstack-packstack
sudo setenforce 0
sudo packstack --allinone
