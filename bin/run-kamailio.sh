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
	--env NETWORK=$NETWORK \
	--env RABBITMQ=$RABBITMQ \
	2600hz/kamailio

IP=$(bin/get-ip.sh $NETWORK $NAME)
echo -n "forwarding sip port 5060 to kamailio $IP "
iptables -t nat -A PREROUTING -p udp --dport 5060 -j DNAT --to-destination $IP
