#!/usr/bin/env python

import sys
import serial
import platform
import time
import re
import signal
import eeml
import eeml.datastream
import time
import urllib2
#from eeml.datastream import CosmError

# Version

Version = "0.70"

# COSM variables. The API_KEY and FEED are specific to your COSM account and must be changed 

#API_KEY = '-=-==-=-=-=FILL THIS OUT-=-=-=-=-=-='
#FEED = -=-=FILL THIS OUT-=-==-=-=-=-=-=
API_KEY = 'mjiyltfoNxqnsU1iVl8RyBgNPvWSAKxVSFh0L0VJNUFIbz0g'
FEED = 128593
MY_PORT = '/dev/ttyUSB1'

API_URL = '/v2/feeds/{feednum}.xml' .format(feednum = FEED)



# capture Ctrl-C so we can close the port or else mac locks up and needs reboot
def signal_handler(signal, frame):
	print "Ctrl-C pressed!"
	if ser.isOpen:
		ser.close()
		sys.exit(0)
ser = serial.Serial(MY_PORT)


signal.signal(signal.SIGINT, signal_handler)



#cosmFeed = eeml.datastream.Cosm(API_URL, API_KEY)
cosmFeed = eeml.datastream.Pachube(API_URL, API_KEY)


print "PowerMeter Uploader v" + Version
print ""

plat = platform.platform()
print "Platform is " + plat

# allow switching from Mac to Pi
if plat.startswith("Darwin"):
	port = '/dev/tty.usbserial-001014FD'
if plat.startswith("Linux"):
	port = MY_PORT
if plat.startswith("Windows"):
	port = '\\.\COM8'


localtime = time.asctime( time.localtime(time.time()))

if ser.isOpen:
	ser.close()


	try:
		ser = serial.Serial(port,115200)
		print "Opened serial port %s\n" % (ser.portstr)
	except:
		sys.stderr.write("Error opening serial port")
		sys.exit(1)

	#request initial readings of demand and power meter
	time.sleep(1)
	ser.write("<Command><Name>get_current_summation_delivered</Name><Refresh>Y</Refresh></Command>")
	time.sleep(1)
	ser.write("<Command><Name>get_instantaneous_demand</Name><Refresh>Y</Refresh></Command>")

running = True

while running:
	n = ser.inWaiting() # how many chars in receive buffer
	if n>0:
		localtime = time.asctime( time.localtime(time.time()))
		currentLine = ser.readline()
		tokenlist = re.findall(r'\w+', currentLine) # This breaks the line up into a list of strings containing the separate words.
		if len(tokenlist) > 0:

			if tokenlist[0] == "Demand":

				hexstr = tokenlist[1]

				debugsw = False
				hcount = len(hexstr)
			 	if hcount > 2:
       					if hexstr[:2] == "0x":
       						hexstr = hexstr[2:]
            
				if debugsw:
       					print "Value to conver to signed: %s " % int(hexstr, 16)
        				print "Length: %s " % int(len(hexstr)) + "Length: %s " % int(len(hexstr))
  				hint = int(hexstr, 16)
  				test = (((2**(len(hexstr)*4))/2)-1)
    				test0 = 2**(len(hexstr)*4)-1 #FFFFFFFF
    				if debugsw:
        				print "Test: %s " % str(test) + "Test0: %s " % str(test0)
    
    				hsigned = hint
    
    				if hint > test:    #2147483647:     
       					hsigned = -((test0 - (int(hexstr, 16))) +1)
    				if debugsw:
       					print hsigned

					
	
				if hsigned !=0: # either from bad hex conversion or sometimes we do get zero reading
					print localtime, " Current Load: ",str(hsigned), "W"
					#Send data to Cosm
					try:
						cosmFeed.update([eeml.Data(0,hsigned)])
						cosmFeed.put()
					except:
						print localtime, " Error writing Current Load to COSM", sys.exc_info()[0]
						ser.close()
						sys.exit(0)


			if tokenlist[0] == "SummationDelivered":
				try:
					CurrentMeterReading = float(int(tokenlist[1],16))/1000 #convert from hex and divide by 1000
				except:
					CurrentMeterReading = 0.0;

				if CurrentMeterReading !=0: # either from bad hex conversion or sometimes we do get zero reading
					print localtime, " Current Meter Import: ",str(CurrentMeterReading), "kWh"
					#Send data to Cosm
					try:
						cosmFeed.update([eeml.Data(1,CurrentMeterReading)])
						cosmFeed.put()
					except:
						print localtime, " Error writing Summation Delivered to COSM", sys.exc_info()[0]
						ser.close()
						sys.exit(0)

			if tokenlist[0] == "SummationReceived":
				try:
					CurrentMeterExport = float(int(tokenlist[1],16))/1000 #convert from hex and divide by 1000
				except:
					CurrentMeterExport = 0.0;

				if CurrentMeterExport !=0: # either from bad hex conversion or sometimes we do get zero reading
					print localtime, " Current Meter Export: ",str(CurrentMeterExport), "kWh"
					#Send data to Cosm
					try:
						cosmFeed.update([eeml.Data(2,CurrentMeterExport)])
						cosmFeed.put()
					except:
						print localtime, " Error writing Meter Export to COSM", sys.exc_info()[0]
						ser.close()
						sys.exit(0)


	else: # if n=0 ie nothing there
		time.sleep(4)
