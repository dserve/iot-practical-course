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
partprobe /dev/vda
resize2fs /dev/vda1
echo partition should be resized
df -Th

cd ..

# remove lock files to prevent apt-get update from failing
sudo su
rm /var/cache/apt/archives/lock
rm /var/lib/dpkg/lock
# install docker-ce
apt-get update
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
apt-get update
apt-get install docker-ce -y
# install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
# increase virtual memory size for elasticsearch
sysctl -w vm.max_map_count=262144
# accept incoming messages for kafka
#iptables -I INPUT -p tcp -m tcp --dport 9092 -j ACCEPT