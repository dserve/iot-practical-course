#!/bin/bash
# resize partition
echo resize partition
df -Th
(
echo d
echo n
echo p
echo 1
echo 
echo 
echo t
echo 83
echo a
echo p
echo w
) | fdisk /dev/vda
df -Th
resize2fs /dev/vda1
echo partition should be resized
df -Th
# remove lock files to prevent apt-get update from failing
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock
# install docker-ce
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
sudo apt-get update
sudo apt-get install docker-ce -y
# install docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# increase virtual memory size for elasticsearch
sudo sysctl -w vm.max_map_count=262144
# accept incoming messages for kafka
iptables -I INPUT -p tcp -m tcp --dport 9092 -j ACCEPT