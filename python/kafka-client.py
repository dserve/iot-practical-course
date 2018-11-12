from kafka import KafkaClient
client = KafkaClient(hosts='35.184.224.167:9094')
client.check_version()
