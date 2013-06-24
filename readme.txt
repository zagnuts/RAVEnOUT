V2 of the RAVEn script, now renamed 'RAVEnOUT' and being written in perl [yes I know, but it's in my comfort zone <grin> ]

If all you want is to have status info of power consumption over the past few minutes and/or over the past month, then you may be better off just using the V1 script.

The key goals for the new script include:
* Ability to save data to a local file for historical use (for example, should you choose in the future to move
to a different system for displaying power usage, you can load your history if you want)
* Ability to load power usage data direct to pvoutput
* Ability to load data directly to Xively (ex COSM, ex Pachube)

Other planned/wish list features:
* More 'error aware' so that cause of issues are easier to identify & resolve

Not all features may be available in the first release, but will attempt to have the keys goals.

___________________________________________________________________________________________________

The below assumes that you have done the other required steps such as:
* Purchased a RAVEn USB device (http://rainforestautomation.com/raven). Note that it is quite likely that the same script will work with an EMU or EMU-2 device (http://rainforestautomation.com/emu-2) but this has not been tested.
* Linked it to your smart meter (eg via the UE portal - https://energyeasy.ue.com.au/)

[To be updated - please be patient. I am having a minor issue in that I'm finding the XML data feed is throwing in random characters that is breaking my alpha script when using the XML::Simple module. Not a major stumbling block, but annoying.]


