#!/bin/sh
NETWORK=${NETWORK:-"kazoo"}
echo Stopping network: $NETWORK
docker stop -t 1 $(docker ps | grep "\.$NETWORK" | cut -d' ' -f1)
