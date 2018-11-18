from kafka import KafkaConsumer
consumer = KafkaConsumer('testing', bootstrap_servers='35.185.115.105:9094')
for msg in consumer:
    print (msg)