var kafka = require('kafka-node'),
    Producer = kafka.Producer,
    KeyedMessage = kafka.KeyedMessage,
    client = new kafka.Client('35.243.198.242:9094'),
    producer = new Producer(client),
    km = new KeyedMessage('key', 'message'),
    payloads = [
        { topic: 'testing', messages: 'hi', partition: 0 },
        { topic: 'testing', messages: ['hello', 'world', km] }
    ];
producer.on('ready', function () {
    console.log('ready');
    producer.send(payloads, function (err, data) {
        console.error(err);
        console.log(data);
    });
});
 
producer.on('error', function (err) {})