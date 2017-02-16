#!/bin/sh
# sanity check
command -v docker >/dev/null 2>&1 || { echo "Docker is required, but missing"; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "Curl is required, but missing"; exit 1; }
command -v iptables >/dev/null 2>&1 || { echo "iptables is required, but unaccessible (please run me as root)"; exit 1; }

export NETWORK=${NETWORK:-"kazoo"}
echo -n "starting network: $NETWORK "
docker network create $NETWORK

if [ -z "$KAZOO_URI" ]
then
	EXT_IP=$(curl -s ipinfo.io/ip)
	echo "Guessing our Kazoo API uri: http://$EXT_IP/api/v2"
	echo "Please specify it in KAZOO_URI env variable, e.g. http://your-server.domain, without api/v2 part, see nginx config"
	KAZOO_URI=http://$EXT_IP
fi
export KAZOO_URL=${KAZOO_URL:-"$KAZOO_URI/api/v2/"}

for SERVICE in rabbitmq couchdb kazoo kamailio freeswitch monster-ui
do
	bin/run-${SERVICE}.sh
done

echo Building and starting nginx frontend to Kazoo
cd nginx && ./build.sh && ./run.sh && cd ../

echo Going to configure Kazoo, please wait for system to start up...
./after-start.sh

echo Completed! Point your browser to $KAZOO_URI!
