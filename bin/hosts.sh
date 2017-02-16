#!/bin/sh
NETWORK=${NETWORK:-"kazoo"}
for NAME in $(docker ps --filter name=\.${NETWORK}\$ --format {{.Names}})
do
	IP=`docker inspect --format "{{ (index .NetworkSettings.Networks \"$NETWORK\").IPAddress }}" $NAME`
	echo $NAME $IP
done
