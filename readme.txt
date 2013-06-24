This was/is the modified python script used to record data from the RAVEn USB dongle, and transfer that to Xively 
(was Pachube, then renamed to COSM, now  currently "Xively"). Feel free to use it, with the understanding that 
there are now limitation to using Xively, including:
* Data is stored for only 30 days
* Maximum of 25 calls per minute
* Data is averaged over time

If you have a 'legacy' (existing) feed, then some of this does not apply for the moment, but for a number of reasons
I have decided to create a new script that will, amongst other things, save a local copy of the data for historical
purposes (you may never use it, but what the hey), send the data to pvoutput (great for charting over time as well
as for those of us with solar installations), and optionally also sent to Xively (still nice to have for that 
immediate display of power consumption).

_____________________________________________________________________________________________________________________


The below assumes that you have done the other required steps such as:
* Purchased a RAVEn USB device (http://rainforestautomation.com/raven)
* Linked it to your smart meter (eg via the UE portal - https://energyeasy.ue.com.au/)
* Got onto Xively and created an account, added a device feed, added three data streams 
to the device feed with IDs of 0, 1, and 2 and then added a key.
* Have a Raspberry Pi (eg http://au.element14.com/raspberry-pi/rpi-b-512-cased/sbc-raspberry-pi-b-512mb-cased/dp/2217158) 
plugged into power, connected to the local network with access to the internet. Be aware that the 'pi is sensitive
to power so make sure you use a decent power supply, plus also the older/cheaper/original 'pi may not provide enough
bus power to the RAVEn in which case you may need to use an external *powered* USB hub.

You can of course should be able to run this script on anything (linux/windows/mac/etc) as long as you're able
to install python. Personally, I use a 'pi as it's one of those setup and forget things - can be used effectively
as an appliance. Anyhow, for the Raspberry PI:

1. Need to make sure it's up to date
  sudo apt-get update

2. Then install serial support
	sudo apt-get install python-serial

3. Install other python tools (probably optional, but I'd do it)
	sudo apt-get install python-dev

4. setup tools
	mkdir python-distribute
	cd python-distribute
	curl -O http://python-distribute.org/distribute_setup.py
	sudo python distribute_setup.py
	cd

5. Then eeml
	wget -O geekman-python-eeml.tar.gz https://github.com/geekman/python-eeml/tarball/master
	tar zxvf geekman-python-eeml.tar.gz
	cd geekman-python-eeml
	sudo python setup.py install
	cd

6. Edit the script to suit
Using nano or similar text editor, and put in your Cosm feed and API details. Change the port details to match. If you have nothing else plugged into your 'pi it will be /dev/ttyUSB0. You can check by typing "dmesg|grep tty" and look for the line that talks about the FTDI USB Serial Device.

7. Run the script (to test)
	python ./cosm.py

_______________________________________

Currently there is an issue with the script where it fails intermittently. As yet the cause has not been identified. Until this is fixed, looping the program on failure is a good short term fix. For the 'pi the following shell script loops the program, and dumps the date/time into a log file so you have an idea as to how frequently this is happening to you.

In the directory where the main "cosm.py" script is, create text file called 'gocosm.sh' as follows:

i=1
for (( ; ; ))
do
 sleep $i
 python cosm.py
 date >>  cosmoops.log
done
_______________________________________

type chmod +x gocosm.sh
run the script by typing "./gocosm.sh"

