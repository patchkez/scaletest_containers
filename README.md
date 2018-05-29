# Scaling testing for Komodo platform

## Prerequisities for localhost testing
- Docker Community Edition (CE) and docker-compose must be installed
- make sure user is member of `docker` group so it can execute docker commands without switching to root user

## Data volume


## Build images
2 images will be built, komodod and marketmaker:
```
docker-compose build marketmaker
```

## Create custom docker network
```
docker network create komodo_scale
```
