# RAVEnOUT
# V0.04

# A simple perl script to retrieve power data from a smart meter using the RAVEn usb from http://rainforestautomation.com/
# Although not tested, it is likely to also work on the EMU and EMU-2 devices.

# Script has been tested on a raspberry pi, but should work on other systems with a recent version of perl

# if you run the script and it fails, it is most likely you need to install the required modules
# This may be done using cpan either directly or via a tool such as cpanminus eg
# sudo apt-get install cpanminus
# sudo cpanm Device::SerialPort --interactive
#
# If running ubuntu, it is probably better to see if there is a package already there to install and use that eg
# sudo apt-get install libxml-libxml-perl
#
#
# Script process logic is as follows:
# - sends a request to get current instantaeneous demand ie how much power is being used at this moment in time
# - captures the response into a temporary file that may be used for troubleshooting
# - processes the data to retrieve the current demand info in watts
# - sends a request to get the amount of power that has been recorded as being used and generated
# - captures the response into a temporary file that may be used for troubleshooting
# - processes the data to retrieve the power used and generated - if you have solar - and converts to kWh
# - captured data is then written to a csv file for history in the format date,time,received,delivered,demand
#
# Issues at moment - sometimes no response is received from the meter in time, in which case the script closes the
# file so no data is captured and the script dies. The script may be run again manually, but my next task is to put
# some smarts into the script to test the file and if it is not valid then to run again. At the moment I have put in
# a small delay, but this is obviously not a permanent fix 
#
# To be done - I want to resolve the above issue, then will now work on option to send the data to remote services 
# such as pvoutput and xively
#
# Note - this script writes temporary and log files to disk. With a raspberry pi, this generally means it is writing
# to an SD card. I only intend to run this once every 10 minutes of so, but if you run this more frequently you may
# want to consider mounting a remote drive and running the script off that to minimise activity on the SD card. In
# the future I may update the script to use an XML parser that can directly access the stream so that saving the 
# temporary and history files may be made optional. 


#!/usr/bin/perl

use strict;
use warnings;

# You may find the following modules are included with your version of perl
# If not, any that are missing will need to be installed
use Device::SerialPort;
use XML::Simple;
use Time::Piece (); 

my $HOMEDIR   = "./";              # path to data files - default is current directory
my $DEMAND    = "demand.xml";      # file name to output instant demand data
my $DELIVERED = "delivered.xml";   # file name to output historical usage data
my $PORT      = "/dev/ttyUSB1";    # port to watch
my $HISTORY   = "RAVEnOUT.csv";    # file name to log historical records

my $port = Device::SerialPort->new($PORT); 
# $port->user_msg(ON); 
$port->baudrate(115200)	|| die "failed setting baudrate"; 
$port->parity("none")	|| die "failed setting parity"; 
$port->databits(8)		|| die "failed setting databits"; 
$port->stopbits(1); 
$port->handshake("none")	|| die "failed setting handshake"; 
$port->write_settings	|| die "no settings";
# $port->lookclear; 


#
my $pass=$port->write("<Command> <Name>get_instantaneous_demand</Name> [<Refresh>Y</Refresh>] </Command>"); # send command to retrieve demand info
sleep 1;	# wait a second to try to ensure we get data

#
# open the logfile, and Port
#

open(LOG,">${HOMEDIR}/${DEMAND}")
    ||die "can't open file $HOMEDIR/$DEMAND\n";

open(DEV, "<$PORT") 
    || die "Cannot open $PORT: $_";

select(LOG), $| = 1;      	# set nonbufferd mode

while($_ = <DEV>){        	# print input device to file
    $_ =~ s/\x00//g;		# filter out null characters 
    print LOG $_;
}
close (LOG);

my $test_data = XMLin($HOMEDIR/$DEMAND);
my $demand = oct($test_data->{Demand});

$pass=$port->write("<Command> <Name>get_current_summation_delivered</Name> [<Refresh>Y</Refresh>] </Command>");
sleep 2;

open(LOG,">${HOMEDIR}/${DELIVERED}")
    ||die "can't open file $HOMEDIR/$DELIVERED\n";

open(DEV, "<$PORT") 
    || die "Cannot open $PORT: $_";

select(LOG), $| = 1;      # set nonbufferd mode

#
# Loop forver, logging data to the log file
#

while($_ = <DEV>){        # print input device to file
    print LOG $_;
}

undef $port;
close (LOG);

open(LOG,">>${HOMEDIR}/${HISTORY}")
    ||die "can't open file $HOMEDIR/$HISTORY\n";
$test_data = XMLin($HOMEDIR/$DELIVERED);
my $received = oct($test_data->{SummationReceived})/1000;
my $delivered = oct($test_data->{SummationDelivered})/1000;
print LOG Time::Piece::localtime->strftime('%Y%m%d,%R');
print LOG ",$received,$delivered,$demand\n";
close LOG;
