from kafka import KafkaConsumer
consumer = KafkaConsumer('foobar', bootstrap_servers='35.184.224.167:9094')
for msg in consumer:
    print (msg)