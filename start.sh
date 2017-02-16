#!/bin/sh
NETWORK=${NETWORK:-"kazoo"}
for SERVICE in rabbitmq couchdb kazoo kamailio freeswitch monster-ui
do
	docker start $SERVICE.$NETWORK
done
