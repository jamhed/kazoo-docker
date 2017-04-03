#!/bin/sh
FLAGS=${1:-"-td"}
NETWORK=${NETWORK:-"kazoo"}
NAME=${NAME:-"kamailio.$NETWORK"}
RABBITMQ=${RABBITMQ:-"rabbitmq.$NETWORK"}

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
	-p 5060:5060/udp \
	--env NETWORK=$NETWORK \
	--env RABBITMQ=$RABBITMQ \
	--env EXT_IP=$EXT_IP \
	2600hz/kamailio
