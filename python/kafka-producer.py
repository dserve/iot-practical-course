from kafka import KafkaProducer
import json
import datetime

producer = KafkaProducer(bootstrap_servers='35.185.56.153:9094')
producer = KafkaProducer(value_serializer=lambda v: json.dumps(v).encode('utf-8'))
producer.send('testing', 1)


# Block until all pending messages are at least put on the network
# NOTE: This does not guarantee delivery or success! It is really
# only useful if you configure internal batching using linger_ms
producer.flush()
