#!/bin/sh
FLAGS=${FLAGS:-"-td"}
NETWORK=${NETWORK:-"kazoo"}
NAME=${NAME:-"freeswitch.$NETWORK"}
KAMAILIO=${KAMAILIO:-"kamailio.$NETWORK"}
RABBITMQ=${RABBITMQ:-"rabbitmq.$NETWORK"}
RTP_START_PORT=${RTP_START_PORT:-"10000"}

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
	--env RABBITMQ=$RABBITMQ \
	--env RTP_START_PORT=$RTP_START_PORT \
	2600hz/freeswitch

echo -n "adding dispatcher $NAME to kamailio $KAMAILIO "
docker exec $KAMAILIO dispatcher_add.sh 1 $NAME

RTP_END_PORT=$( expr $RTP_START_PORT + 999 )
IP=$(bin/get-ip.sh $NETWORK $NAME)
echo "forwarding rtp range $RTP_START_PORT:$RTP_END_PORT to freeswitch $IP"
iptables -t nat -A PREROUTING -p udp -m multiport --dport $RTP_START_PORT:$RTP_END_PORT -j DNAT --to-destination $IP
iptables -A FORWARD -p udp -m multiport --dport  $RTP_START_PORT:$RTP_END_PORT -d $IP -j ACCEPT
