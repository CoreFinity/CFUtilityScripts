#!/bin/bash

cd ~

for f in {passwd,group,shadow,gshadow}.bak; do cat $f >>/etc/${f%.bak}; done

for uidgid in $(cut -d: -f3,4 passwd.bak); do
    dir=$(awk -F: /$uidgid/{print\$6} passwd.bak)
    mkdir -pvm700 "$dir"; cp -r /etc/skel/.[[:alpha:]]* "$dir"
    chown -R $uidgid "$dir"; ls -ld "$dir"
done