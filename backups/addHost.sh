#!/bin/bash
#
# Adds a host to backup system (must be ran on the backup server)
#
# Create the main config file for the host to be backed-up by rsnapshot
# taking the hostname from the first argument to bash
# this is assuming ansible/someone has already added the public key of the backup server to the box
# you can call this script manually to add another host into the backup system as such:
# ./addhost hostname.com
# where first argument is a host that is accessible to the backup server via keyless ssh
#
mkdir -p /home/backups/$1/files/
mkdir /home/backups/$1/configs
mkdir /home/backups/$1/dbs

# randomise minute the backup is done, between 0 and 60 seconds
MINUTE=(`awk -v min=0 -v max=60 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'`)

# randomise the hour the back is done between 1 and 5am
HOUR=(`awk -v min=1 -v max=5 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'`)

# cronFile, remove dots from hostname as unix based systems seem to ignore cron files in cron.d/ directory if they have a dot in them, go figure
cronFile=${1//[-._]/}

echo $cronFile
echo 1

echo -e "include_conf\t/etc/rsnapshot-common.conf

snapshot_root\t/home/backups/$1/files/

interval\thourly\t24
interval\tdaily\t7
interval\tweekly\t4
interval\tmonthly\t3

logfile\t/home/backups/$1/rsnapshot.log
lockfile\t/home/backups/$1/rsnapshot.pid

exclude_file\t/home/backups/$1/configs/excludes.conf

backup\troot@$1:/\t./\t+rsync_long_args=--bwlimit=35000
" >> /home/backups/$1/configs/rsnapshot.conf

# Create a include/exclude file
echo "# Vortex backup
# Currently excluding everything and backing up /etc/ /home/ /root/ /lib/ /lib64/ /usr/ /var/
#
- /bin
- /boot
- /dev
- /initrd.img
- /lost+found
- /media
- /mnt
- /opt
- /proc
- /run
- /sbin
- /srv
- /sys
- /tmp
- /var/run
- /var/lock
- /vmlinuz
- /var/lib/mysql
+ /*" > /home/backups/$1/configs/excludes.conf

# Create a crobtab file for this host
# To ease management each host has it's own crontab file
echo "#
# Backup cron for host $1
# This file is auto generated, and unless you edit the template file within CFUtilityScripts/Backups/addHost.sh, it will probably be overwritten

$MINUTE */6 * * *  root rsnapshot -c /home/backups/$1/configs/rsnapshot.conf sync && rsnapshot -c /home/backups/$1/configs/rsnapshot.conf hourly
$MINUTE $HOUR * * * root rsnapshot -c /home/backups/$1/configs/rsnapshot.conf daily
$MINUTE $HOUR * * 0 root rsnapshot -c /home/backups/$1/configs/rsnapshot.conf weekly
$MINUTE $HOUR 1 * * root rsnapshot -c /home/backups/$1/configs/rsnapshot.conf monthly
$MINUTE */12 * * * root sh /root/vortexdbbackup.sh $1
" > /etc/cron.d/$cronFile
