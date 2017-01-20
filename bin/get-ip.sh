#!/bin/sh
NETWORK=$1
NAME=$2
docker inspect --format "{{ (index .NetworkSettings.Networks \"$NETWORK\").IPAddress }}" $NAME
