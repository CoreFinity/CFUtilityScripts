#!/bin/bash -x
#Find .sql files and varieats, this can be expanded with other file checks. 

timestamp() {
  date +"%b-%d-%y-%T"
}

vhostPath=$(/usr/bin/CFScripts/ansible/getNginxVhostPath.sh)

find_sql=$(find $vhostPath -name '*.test' -o -name '*.test.*')
if [ -z "$find_sql" ]; then
   exit 0
else
   echo "$(timestamp): CRITICAL: Sql in document root!" >> /var/log/filemon.log
fi
