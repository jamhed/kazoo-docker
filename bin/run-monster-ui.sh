#!/bin/sh
FLAGS=${1:-"-td"}
NETWORK=${NETWORK:-"kazoo"}
KAZOO_URL=${KAZOO_URL:-"http://kazoo.$NETWORK:8000/v2/"}
NAME=monster-ui.$NETWORK
if [ -n "$(docker ps -aq -f name=$NAME)" ]
then
   echo -n "stopping: "
   docker stop -t 1 $NAME
   echo -n "removing: "
   docker rm -f $NAME
fi
echo -n "starting: $NAME "
docker run $FLAGS \
	--net $NETWORK \
	-h $NAME \
	--name $NAME \
	--env NETWORK=$NETWORK \
	--env KAZOO_URL=$KAZOO_URL \
	2600hz/monster-ui
