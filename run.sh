#!/bin/sh
export NETWORK=${NETWORK:-"kazoo"}
echo -n "starting network: $NETWORK "
docker network create $NETWORK

for SERVICE in rabbitmq couchdb kazoo kamailio freeswitch monster-ui
do
	bin/run-${SERVICE}.sh
done
