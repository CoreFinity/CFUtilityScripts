#!/bin/bash
#
# Takes the first argument as vhost path, decides if M1 or M2
# Downloads appropriate magedbdump script in root vhost directory
# runs a -d -z backup
# backup file is put into var/db.sql.gz and is then rotated with logrotate
#

# variables used throughout
vhostPath=$1
m1config=$vhostPath"/app/etc/local.xml"
m2config=$vhostPath"/app/etc/env.php"
cfutilityscript="/usr/bin/CFScripts"
m1scriptfilename="mage-dbdump-m1.sh"
m2scriptfilename="mage-dbdump-m2.sh"
m1script=$cfutilityscript"/generic/$m1scriptfilename"
m2script=$cfutilityscript"/generic/$m2scriptfilename"
latestdbfilepath=$vhostPath"/var/latest.sql.gz"

# if m1
if [ -f $m1config ]; then
    scriptFileName=$m1scriptfilename
    scriptToUse=$m1script
    echo "Found m1 site"
fi
# elseif m2
if [ -f $m2config ]; then
    scriptFileName=$m2scriptfilename
    scriptToUse=$m2script
    echo "Found m2 site"
fi

# Copy correct script to the vhost path and build the backup command
cp $scriptToUse $vhostPath

chmod +x $vhostPath$scriptFileName
backupCommand="$vhostPath$scriptFileName -d -z"

# Run the DB backup script
echo "Backing up the database"
(cd $vhostPath; eval $backupCommand)

# If latest.sql.gz exists, Move it to it's date modified time
# This means the file name will be db-2018-02-27-13-32-03-453896170-0000.sql.gz
dateModified=$(cd $vhostPath; stat -c %y "var/latest.sql.gz")
fileName=$(cd $vhostPath; echo $dateModified | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z)
fileName="$vhostPath/var/db-$fileName.sql.gz"

echo $latestdbfilepath
if [ -f $latestdbfilepath ]; then
    echo "Moving old latest.sql.gz file to $fileName"
    mv $latestdbfilepath $fileName
fi

# Delete any files that match the filename and are older than 7 days
echo "Deleting databases backups older than 7 days"
#(find $vhostPath/var/ -name "db-*.gz" -mtime +15 | xargs rm -f)

# Move the file to latest.sql.gz
echo "Moving file from var/db.sql.gz to $latestdbfilepath"
(cd $vhostPath/var/; mv db.sql.gz $latestdbfilepath)

echo "Database backup complete"