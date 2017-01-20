#!/bin/sh
NETWORK=${NETWORK:-"kazoo"}
echo wait for kazoo.$NETWORK to start '(you may check docker logs if impatient)'
watch -g "docker logs kazoo.$NETWORK | grep 'auto-started kapps'" > /dev/null

cd kazoo
echo -n "create master account: "
./sup crossbar_maintenance create_account admin kamailio.$NETWORK admin admin
echo -n "add freeswitch to kazoo: "
./sup ecallmgr_maintenance add_fs_node freeswitch@freeswitch.$NETWORK

echo -n "enable console debug: "
./sup kazoo_maintenance console_level debug

echo wait fot freeswitch to complete connect
watch -g "docker logs kazoo.$NETWORK | grep 'max_channel_cleanup_timeout_ms'" > /dev/null

IP=$(docker inspect --format "{{ .NetworkSettings.Networks.$NETWORK.IPAddress }}" kamailio.$NETWORK)
echo -n "add kamailio to kazoo with ip $IP: "
./sup ecallmgr_maintenance allow_carrier kamailio.$NETWORK $IP

echo import default kazoo sounds
git clone --depth 1 --no-single-branch https://github.com/2600hz/kazoo-sounds
docker cp kazoo-sounds/kazoo-core/en/us kazoo.$NETWORK:/home/user
./sup kazoo_media_maintenance import_prompts /home/user/us en-us
docker exec -i --user root kazoo.$NETWORK rm -rf us

echo enable monster-ui applications
docker cp monster-ui.$NETWORK:/usr/share/nginx/html/src/apps apps
docker cp apps kazoo.$NETWORK:/home/user
rm -rf apps
./sup crossbar_maintenance init_apps /home/user/apps http://kazoo.$NETWORK:8000/v2
docker exec -i --user root kazoo.$NETWORK rm -rf apps

echo refresh kamailio dispatcher
docker exec -i kamailio.$NETWORK kamcmd dispatcher.reload 

echo commit couchdb to couchdb-init
docker commit couchdb.$NETWORK $NETWORK/couchdb-init
cd ../
