#!/bin/sh
NETWORK=${NETWORK:-"kazoo"}
echo Stopping network: $NETWORK
docker stop -t 1 $(docker ps --filter name=\.${NETWORK}\$ --format {{.ID}})
