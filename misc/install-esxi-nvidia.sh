#!/bin/bash

echo "Installing Nvidia Driver with 12.1 CUDA"
echo "Nvidia version: 530.30.02 / CUDA 12.1"

touch /etc/modprobe.d/blacklist-nvidia-nouveau.conf
cat >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf << EOF
blacklist nouveau
options nouveau modeset=0
EOF
touch /etc/modprobe.d/nvidia.conf
cat >> /etc/modprobe.d/nvidia.conf << EOF
options nvidia NVreg_OpenRmEnableUnsupportedGpus=1
EOF
sudo update-initramfs -u

mkdir fuck-you-nvidia

wget https://download.nvidia.com/XFree86/Linux-x86_64/530.30.02/NVIDIA-Linux-x86_64-530.30.02.run -P fuck-you-nvidia
wget https://developer.download.nvidia.com/compute/cuda/12.1.0/local_installers/cuda_12.1.0_530.30.02_linux.run -P fuck-you-nvidia

chmod +x fuck-you-nvidia/*.run

sudo apt install build-essential -y
sudo apt install pkg-config libglvnd-dev -y

echo "After reboot install Nvidia driver by"
echo "sudo ./NVIDIA-Linux-x86_64-530.30.02.run  -m=kernel-open"

sudo reboot
