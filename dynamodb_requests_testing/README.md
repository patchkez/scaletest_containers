# Howto
## Build image
```
docker-compose -f docker-compose-dynamodb-test.yml build TXSCL000
```

## Start all containers as daemons
```
docker-compose -f docker-compose-dynamodb-test.yml up -d
```

Note: If you want to see stdout, remove `-d` option.

## Start one container
```
docker-compose -f docker-compose-dynamodb-test.yml up -d TXSCL000
```

