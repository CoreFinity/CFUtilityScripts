#!/bin/bash
function regex1 { gawk 'match($0,/'$1'/, ary) {print ary['${2:-'1'}']}'; }
cat /etc/nginx/conf.d/*.conf | regex1 'root\s+([\/a-z0-9-.]+);' | sed -n 1p