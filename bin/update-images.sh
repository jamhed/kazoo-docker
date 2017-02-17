#!/bin/sh
for IMAGE in $(docker images --format {{.Repository}} | grep 2600hz | grep -v nginx)
do
	docker pull $IMAGE
done
