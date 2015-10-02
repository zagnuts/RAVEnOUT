V2 of the RAVEn script, now renamed 'RAVEnOUT' and being written in perl [yes I know, but it's in my comfort zone <grin> ]

If all you want is to have status info of power consumption over the past few minutes and/or over the past month, then you may be better off just using the original python based V1 script.

The key goals for the new script include:
* Ability to save data to a local file for historical use (for example, should you choose in the future to move to a different system for displaying power usage, you can load your history if you want)
* Ability to load power usage data direct to pvoutput
* Ability to load data directly to Xively (ex COSM, ex Pachube)

Other planned/wish list features include:
* More 'error aware' so that cause of issues are easier to identify & resolve
* Saving data in RRDtool (http://oss.oetiker.ch/rrdtool/) format to enable simple charting on website
* Able to run as a daemon/background process

Not all features may be available in the first release, but will attempt to achieve the key goals.

___________________________________________________________________________________________________

The below assumes that you have done the other required steps such as:
* Purchased a RAVEn USB device (http://rainforestautomation.com/raven). Note that it is quite likely that the same script will work with an EMU or EMU-2 device (http://rainforestautomation.com/emu-2) but this has not been tested.
* Linked it to your smart meter (eg via the UE portal - https://energyeasy.ue.com.au/)

Update - 1 July 2013
Have resolved the issue with the data - found it was simple null characters so just had to work out how
to filter them. Have now released the initial version of the script - still a work in progress as will only save
the data to a CSV file locally, but should not take long to add in support for uploading to external sevices.

Update - 2 Oct 2015
Well, it has been a while. I have a V05 version that I started working on way back when, but ran out of available
time to finish. I since found a number of people were using the script to upload data to pvoutput, but the way it
was being used was probably not the best. To try to help those, what I've done is hack the original perl script to
JUST dump the instantaneous data that the pvoutput 'ravenpost.js' needs, and do that fairly reliably.

To use, just change from RAVEnOUT.pl to RAVEnPV.pl. The data will still be dumped into demand.xml, but it won't
have all that other stuff in it that could cause the upload to fail. 

If you are not currently using this and want to give it a try, I have a sample upload script as well - just edit it and
put in your pvoutput details.

Sometime, honest, sometime I'll work on the main script and have it upload the data directly as well as optionally save
the history to a log file etc etc etc. Cheers.
