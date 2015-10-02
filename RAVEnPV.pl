# RAVEnPV - V01
#
# Quick hack to *just* create a log file that contains the instantaneous demand
#
# Create a script called pvlogger.sh to use

#!/usr/bin/perl

use strict;
use warnings;
use Device::SerialPort;
use XML::Simple;
use Time::Piece ();

my $HOMEDIR   = "./";              # path to data files - default is current di$
my $DEMAND    = "demand.xml";      # file name to output instant demand data
my $PORT      = "/dev/ttyUSB1";    # port to watch

my $port = Device::SerialPort->new($PORT);
$port->baudrate(115200) || die "failed setting baudrate";
$port->parity("none")   || die "failed setting parity";
$port->databits(8)              || die "failed setting databits";
$port->stopbits(1);
$port->handshake("none")        || die "failed setting handshake";
$port->write_settings   || die "no settings";
#
my $pass=$port->write("<Command> <Name>get_instantaneous_demand</Name> [<Refresh>Y</Refresh>] </Command>"); # send command to retrieve demand info
sleep 1;        # wait a second to try to ensure we get data
#
# open the logfile, and Port
#
open(LOG,">${HOMEDIR}/${DEMAND}")
    ||die "can't open file $HOMEDIR/$DEMAND\n";

open(DEV, "<$PORT")
    || die "Cannot open $PORT: $_";

select(LOG), $| = 1;            # set nonbufferd mode

while($_ = <DEV>){              # print input device to file
    $_ =~ s/\x00//g;            # filter out null characters 
    print LOG $_;
}
