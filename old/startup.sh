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

# Maven

sudo apt-get install maven -y

# Node & NPM

sudo apt install nodejs -y
sudo apt install npm -y
sudo ln -s `which nodejs` /usr/bin/node

# Zookeeper
sudo apt install zookeeperd -y

# Download all packages
cd ~
wget http://apache.lauf-forum.at/kafka/1.1.0/kafka_2.12-1.1.0.tgz &
wget http://apache.lauf-forum.at/flink/flink-1.4.2/flink-1.4.2-bin-hadoop28-scala_2.11.tgz &
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.3.tar.gz &
wait


# Kafka and relevant packages

sudo tar -xvf kafka_2.12-1.1.0.tgz -C /opt
rm kafka_2.12-1.1.0.tgz
sudo apt install python3-pip -y
sudo pip3 install kafka-python
cd /opt/kafka_2.12-1.1.0
sudo ./bin/kafka-server-start.sh ./config/server.properties &
sleep 10s
./bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic testing
./bin/kafka-topics.sh --list --zookeeper localhost:2181
#./bin/kafka-consoleproducer.sh --broker-list localhost:9092 --topic testing
#./bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic testing –from-beginning
cd ~


# Flink

sudo tar -xvf flink-1.4.2-bin-hadoop28-scala_2.11.tgz -C /opt
rm flink-1.4.2-bin-hadoop28-scala_2.11.tgz
cd /opt/flink-1.4.2-bin-hadoop28-scala_2.11
sudo ./bin/start-local.sh
cd ~

# Elasticsearch:

(
echo 7632blabla
echo 7632blabla
echo
echo
echo
echo
echo
echo Y
) | adduser yourname
cd ~
tar -xvf elasticsearch-5.6.3.tar.gz -C /opt
rm elasticsearch-5.6.3.tar.gz
cd /opt/elasticsearch-5.6.3
su yourname -c "./bin/elasticsearch &"
sleep 20s
curl -XPUT 'localhost:9200/testindex?pretty&pretty'
curl -XGET 'localhost:9200/_cat/indices?v&pretty'
curl -XPUT 'localhost:9200/testindex/agents/1?pretty&pretty' -H 'Content-Type: application/json' -d ' { "name": "James Bond" } '
curl -XGET 'localhost:9200/testindex/agents/1?pretty&pretty'
cd ~

