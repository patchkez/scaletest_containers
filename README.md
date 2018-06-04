# Scaling testing for Komodo platform

## Prerequisities for localhost testing
- Docker Community Edition (CE) and docker-compose must be installed
- make sure user is member of `docker` group so it can execute docker commands without switching to root user

## Data volume


## Build images
Build the TxBlaster Image:
```
docker-compose build
```

## Create custom docker network
```
docker network create komodo_scale
```

## Start all containers
```
docker-compose up -d
```

The seed node will launch and listen for connections on its P2P_PORT, once the ac container has connected to the miner container, the miner will start mining blocks.
On the mining of a block, the blocknotify.sh script will be called on both nodes. This will fetch `start` from a central website. When this file has been changed to `start=1` the process begins. 

> First the 1 payment test is run, where a blaster is launched on both nodes.

> Then the 100 payment test will be run, there the blaster on the mining node is not used. 

> The -ac docker container's push a JSON of basic stats to AWS DynanmoDB. example:'

`{ "size": 1999005, "height": 97, "time": 1528111485, "totaltx": 8859, "ac": "TXSCL220", "mempooltx": 53053, "mempoolMB": 11 }`
