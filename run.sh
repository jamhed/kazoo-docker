#!/bin/sh
NETWORK=${1:-"kazoo"}
export NETWORK
echo -n "starting network: $NETWORK "
docker network create $NETWORK

bin/run-rabbitmq.sh
bin/run-couchdb.sh

bin/run-kazoo.sh
bin/run-kamailio.sh
bin/run-freeswitch.sh

bin/run-monster-ui.sh
