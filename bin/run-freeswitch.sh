#!/bin/sh
FLAGS=${FLAGS:-"-td"}
NETWORK=${NETWORK:-"kazoo"}
NAME=freeswitch.$NETWORK
KAMAILIO=${KAMAILIO:-"kamailio.$NETWORK"}

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
	--env RABBITMQ=${RABBITMQ:-"rabbitmq.$NETWORK"} \
	2600hz/freeswitch

echo -n "adding dispatcher $NAME to kamailio $KAMAILIO "
docker exec $KAMAILIO dispatcher_add.sh 1 $NAME
