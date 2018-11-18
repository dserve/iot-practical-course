# Needed modules will be imported and configured
import RPi.GPIO as GPIO
from kafka import KafkaProducer
import time

producer = KafkaProducer(bootstrap_servers='35.185.115.105:9094')
    
GPIO.setmode(GPIO.BCM)
    
# Declaration of the input pin which is connected with the sensor. Additional to that, a pullup resistor will be activated.
GPIO_PIN = 24
GPIO.setup(GPIO_PIN, GPIO.IN)
    
print "Sensor-test [press ctrl+c to end]"
    
# This outFunction will be started after a signal was detected.
def outFunction(null):
        if(GPIO.input(GPIO_PIN)):
                print('rising edge, send 1')
                producer.send('testing', b'1')
        else:
                print('falling edge, send 0')
                producer.send('testing', b'0')
        
    
# The outFunction will be started after a signal (falling signal edge) was detected.
GPIO.add_event_detect(GPIO_PIN, GPIO.BOTH, callback=outFunction, bouncetime=100) 
    
# main program loop
try:
        while True:
                time.sleep(1)
    
# Scavenging work after the end of the program
except KeyboardInterrupt:
        GPIO.cleanup()
