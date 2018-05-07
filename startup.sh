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
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock
# install docker-ce
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common -y

# increase virtual memory size for elasticsearch
sudo sysctl -w vm.max_map_count=262144
# accept incoming messages for kafka
#iptables -I INPUT -p tcp -m tcp --dport 9092 -j ACCEPT

# Install Java
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt update
sudo apt install oracle-java8-installer -y

# Zookeeper
sudo apt install zookeeperd -y

# Kafka and relevant packages

wget http://apache.lauf-forum.at/kafka/1.1.0/kafka_2.12-1.1.0.tgz
sudo tar -xvf kafka_2.12-1.1.0.tgz -C /opt
rm kafka_2.12-1.1.0.tgz
sudo apt install python3-pip
sudo pip3 install kafka-python
cd /opt/kafka_2.12-1.1.0
sudo ./bin/kafka-server-start.sh &
cd ~

# Flink

wget http://apache.lauf-forum.at/flink/flink-1.4.2/flink-1.4.2-bin-hadoop28-scala_2.11.tgz
sudo tar -xvf flink-1.4.2-bin-hadoop28-scala_2.11.tgz -C /opt
rm flink-1.4.2-bin-hadoop28-scala_2.11.tgz
cd /opt/flink-1.4.2-bin-hadoop28-scala_2.11
sudo ./bin/start-local &
cd ~

# Elasticsearch:

adduser yourname
su yourname
cd ~
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.3.tar.gz
tar -xvf elasticsearch-5.6.3.tar.gz -C /opt
rm elasticsearch-5.6.3.tar.gz
cd /opt/elasticsearch-5.6.3
./bin/elasticsearch &
cd ~

# Maven

sudo apt-get install maven

# Node & NPM

sudo apt install nodejs
sudo apt install npm