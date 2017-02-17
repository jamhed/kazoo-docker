#!/bin/sh
FLAGS=${FLAGS:-"-td"}
NETWORK=${NETWORK:-"kazoo"}
NAME=couchdb.$NETWORK

if [ -n "$(docker ps -aq -f name=$NAME)" ]
then
   echo -n "stopping: "
   docker stop -t 1 $NAME
   echo -n "removing: "
   docker rm -f $NAME
fi

docker volume create couchdb-data.$NETWORK

echo -n "starting: $NAME "
docker run $FLAGS \
	--net $NETWORK \
	-h $NAME \
	--name $NAME \
	-v couchdb-data.$NETWORK:/opt/couchdb/data \
	2600hz/couchdb
