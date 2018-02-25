#!/bin/bash
#
# Takes the first argument as vhost path, decides if M1 or M2
# Downloads appropriate magedbdump script in root vhost directory
# runs a -d -z backup
# backup file is put into var/db.sql.gz and is then rotated with logrotate
#
vhostPath=$1
echo vhostPath
m1config="$vhostPath/app/etc/local.xml"
m2config="$vhostPath/app/etc/env.php"