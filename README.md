Kazoo Docker Deployment
=======================

Preface
=======

This is production (stripped down to bare minimum) version of [Kazoo Docker](https://github.com/2600hz/docker). If you plan
to alter source code or to develop features please consider it.


Notes
=====

The intended use case is to quickly convert a VPS with Docker to complete Kazoo instance. Installation scripts
tries to automatically determine hosts external IP address and deduce Kazoo API URL from it. This could be
overriden with `KAZOO_URL` environment variable.

As Kazoo differentiate clients by realms, and realms are domains, you also need to have a dedicated domain
name server that could resolve all subdomains to single Kazoo IP address. Same could be done manually if number of
sub-accounts is small.

In order to make Kazoo instance useful one also needs a VoIP carrier to provide PSTN numbers to dial into Kazoo,
and same/another VoIP carrier to handle outgoing calls. 

There is a docker volume `couchdb-data` to persistently store all Kazoo data. In case to get a clean install
this volume should be removed with `docker volume rm NAME` command.

Each container is parametrized by NETWORK envirinment variable, with default value set to `kazoo`. By defining 
this variable it is possible to run several Kazoo instances on the same host.

Networking
==========

There is a Nginx container provided to route HTTP requests to Monster UI (main Kazoo frontend) and to Kazoo API itself
with exposed HTTP port 80. UDP port 5060 is exposed by Docker to provide access to Kazoo Kamailio instance to enable
SIP devices to register and make calls. Provided FreeSWITCH instances are parametrized by RTP port range
(1000 ports per container by default), and there are some manual iptables manipulations in `run-freeswitch.sh`
script to route RTP traffic to the specific FreeSWITCH container.

Init
====

You need to have Docker version at least 1.9.0 (as this setup relies on docker network heavily).
Also you need to make sure curl and git are installed, and iptables is runnable.

```sh
git clone https://github.com/jamhed/kazoo-docker
cd kazoo-docker && ./run.sh
```

You can stop the Kazoo instance with `stop.sh` script, and start it back with `start.sh` script anytime.

After start
===========

To initialize the system after first run (with empty database) there is after-start.sh script that:

1. Creates a master account admin with password admin
2. Adds freeswitch node to Kazoo
3. Registers sound prompts
4. Registers Monster-UI 'apps'

The `after-start.sh` script is called automatically by `run.sh`.

Kazoo Erlang console
====================

```sh
docker exec -ti kazoo.kazoo ./run.sh remote_console
```

Kazoo sup
=========

`sup` is a way to issue commands directly to Kazoo, please consult Kazoo documentation for more information.

Please note that `sup` script provided here is a mere wrapper of `docker exec -ti kazoo.kazoo sup`. If you have several
Kazoo instances on the same host or have used different network name then the proper use of sup script is `NETWORK=network_name ./sup [sup_args]`

```sh

# Running apps
./sup kapps_controller running_apps

# Add Freeswitch node
./sup ecallmgr_maintenance add_fs_node freeswitch@freeswitch.kazoo

# Get freeswitch nodes (should be [<<"freeswitch@freeswitch.kazoo">>])
./sup ecallmgr_config get fs_nodes

# Add admin user
./sup crossbar_maintenance create_account admin_name kamailio.kazoo admin admin

# Import Kazoo voice prompts
./sup kazoo_media_maintenance import_prompts /home/user/kazoo-sounds/kazoo-core/en/us en-us

# Check RabbitMQ
./sup kazoo_amqp_maintenance connection_summary
```

Sanity check
============

## Check Kazoo status (this is probably what you should see)

```sh
$ docker exec kazoo.kazoo sup kz_nodes status

Node          : kazoo@kazoo.kazoo
Version       : 4.0.0 - 18
Memory Usage  : 190.55MB
Processes     : 1816
Ports         : 52
Zone          : local
Broker        : amqp://rabbitmq.kazoo:5672
WhApps        : blackhole(4m19s)         callflow(4m19s)          cdr(4m19s)               conference(4m19s)        
                crossbar(4m19s)          doodle(4m18s)            ecallmgr(4m18s)          fax(4m18s)               
                hangups(3m58s)           hotornot(3m58s)          jonny5(3m58s)            kazoo_globals(4m20s)     
                konami(3m58s)            media_mgr(3m58s)         milliwatt(3m58s)         omnipresence(3m58s)      
                pivot(3m58s)             registrar(3m58s)         reorder(3m58s)           runtime_tools            
                stepswitch(3m58s)        sysconf(4m19s)           teletype(3m58s)          trunkstore(3m58s)        
                webhooks(3m58s)          
Channels      : 0
Registrations : 0
Media Servers : freeswitch@freeswitch.kazoo (3m51s)

Node          : kamailio@kamailio.kazoo
Version       : 5.0.0-dev4
Memory Usage  : 14.27MB
Processes     : 0
Ports         : 0
Zone          : local
Broker        : amqp://rabbitmq.kazoo:5672
WhApps        : kamailio(17m37s)
```

## Check Kazoo knows about Kamailio instance

```sh
$ docker exec kazoo.kazoo sup ecallmgr_maintenance acl_summary
+--------------------------------+-------------------+---------------+-------+------------------+----------------------------------+
| Name                           | CIDR               | List          | Type  | Authorizing Type | ID                               |
+================================+===================+===============+=======+==================+==================================+
| kamailio.kazoo                 | 172.18.0.5/32      | authoritative | allow | system_config    |                                  |
+--------------------------------+-------------------+---------------+-------+------------------+----------------------------------+
```

## Check Kamailio has FreeSwitch as dispatcher

```
$ docker exec kamailio.kazoo kamcmd dispatcher.list | grep URI
URI: sip:freeswitch.kazoo:11000
```

Monster-UI
==========

How to register Monster-UI apps:

1. You need to have monster-ui and kazoo images running
2. You need to copy apps from monster-ui to kazoo
3. You need to 'register' these apps

```sh
docker cp monster-ui.kazoo:/usr/share/nginx/html/dist/apps apps
docker cp apps kazoo.kazoo:/home/user
rm -rf apps
cd kazoo
./sup crossbar_maintenance init_apps /home/user/apps $KAZOO_URL
```

After you have added applications to Kazoo you need to enable them to be accessible by users. You can do it using Kazoo Monster UI.

TODO
====

1. Make two instances of Kazoo to work together, probably on different hosts.
2. Provide docker container with domain name server.
3. Integrate Nginx with letsencrypt to setup HTTPS by default.
4. Enable websockets by default.
5. Provide a way to automatically test setup (with MakeBusy), either external or internal.
