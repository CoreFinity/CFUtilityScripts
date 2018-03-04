#!/bin/bash
# Use gawk to match rejex and return capture group
function regex1 { gawk 'match($0,/'$1'/, ary) {print ary['${2:-'1'}']}'; }
# Search all nginx confs to find the vhost path
# this rejex will match the following
# root /var/www/vhosts/domain.com/htdocs;
# and return
# /var/www/vhosts/domain.com/htdocs
# Supports: M1/Shopware config
vhostPath=`cat /etc/nginx/conf.d/*.conf | regex1 'root\s+([\/a-zA-Z0-9_.-]+);' | sed -n 1p`
# If path is empty, assume M2 and use the following rejext, this rejex will march the following
# set $MAGE_ROOT /var/www/vhosts/domain.co.uk/htdocs;
# and return
# /var/www/vhosts/domain.com/htdocs
if [ -z "$vhostPath" ]
then
    vhostPath=$(cat /etc/nginx/conf.d/*.conf | regex1 'set\s+\$MAGE_ROOT\s+([\/a-zA-Z0-9_.-]+);' | sed -n 1p)
fi
case "$vhostPath" in
*/)
    vhostPath="$vhostPath"
    ;;
*)
    vhostPath="$vhostPath/"
    ;;
esac
echo "$vhostPath"
exit
