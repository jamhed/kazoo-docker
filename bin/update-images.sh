#!/bin/sh
docker pull -f $(docker images --format {{.Repository}})
