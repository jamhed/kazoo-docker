#!/bin/sh
docker rmi -f $(docker images --format {{.ID}})
