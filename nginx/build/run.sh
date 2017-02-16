#!/bin/sh
rm -f /etc/nginx/conf.d/default.conf
sed -i s/NETWORK/$NETWORK/g /etc/nginx/conf.d/kazoo.conf
set -e
exec nginx -g "daemon off;"
