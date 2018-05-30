# Scaling testing for Komodo platform

## Prerequisities for localhost testing
- Docker Community Edition (CE) and docker-compose must be installed
- make sure user is member of `docker` group so it can execute docker commands without switching to root user

## Data volume


## Build images
Build the TxBlaster Image:
```
docker build komodod -t testkomodo
```

## Create custom docker network
```
docker network create komodo_scale
```

## Start all containers
```
docker-compose up -d
```

The seed node will launch and listen for connections on its P2P_PORT, once the ac image has connected to the miner image, the miner will start mining blocks.
> At block 3 the ac image will import the privatekey, and launch marketmaker. 

> At block 5 the ac chain will send the `amount` to the `address` 

> At block 8 the TxBlaster loop will be called. Any time the mempool is under 5mb in size marketmaker will send 10,000 TX's.


