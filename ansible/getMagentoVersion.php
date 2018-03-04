#!/bin/bash
#
# Takes the first argument as vhost path, decides if M1 or M2 and returns value 1 or 2 or none
#

# variables used throughout
vhostPath=$1
m1config=$vhostPath"/app/etc/local.xml"
m2config=$vhostPath"/app/etc/env.php"

# if m1
if [ -f $m1config ]; then
scriptFileName=$m1scriptfilename
scriptToUse=$m1script
echo "1"
exit 0
fi
# elseif m2
if [ -f $m2config ]; then
scriptFileName=$m2scriptfilename
scriptToUse=$m2script
echo "2"
exit 0
fi
echo "none"