#!/bin/sh
FLAGS=${1:-"-td"}
NETWORK=${NETWORK:-"kazoo"}
NAME=kazoo.$NETWORK
docker stop -t 1 $NAME
docker rm -f $NAME
docker run $FLAGS \
	--net $NETWORK \
	-h $NAME \
	--name $NAME \
	--env NETWORK=kazoo \
	--env COUCHDB=couchdb.$NETWORK \
	--env RABBITMQ=rabbitmq.$NETWORK \
	--env NODE_NAME=kazoo \
	--env KAZOO_APPS=sysconf,blackhole,callflow,cdr,conference,crossbar,fax,hangups,media_mgr,milliwatt,omnipresence,pivot,registrar,reorder,stepswitch,teletype,trunkstore,webhooks,ecallmgr \
	2600hz/kazoo
