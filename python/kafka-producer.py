from kafka import KafkaProducer
import json
import datetime

producer = KafkaProducer(bootstrap_servers='35.185.115.105:9094')
future = producer.send('testing', b'1')


# Block until all pending messages are at least put on the network
# NOTE: This does not guarantee delivery or success! It is really
# only useful if you configure internal batching using linger_ms
producer.flush()
result = future.get(timeout=60)
print(result)
