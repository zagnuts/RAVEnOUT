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

Update - 1 July 2012
Have resolved the issue with the data - found it was simple null characters so just had to work out how
to filter them. Have now released the initial version of the script - still a work in progress as will only save
the data to a CSV file locally, but should not take long to add in support for uploading to external sevices.


