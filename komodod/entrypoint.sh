#!/bin/bash

KOMODO_HOME="/home/komodo"

if [ -f /home/komodo/.komodo/${ASSET_NAME}/${ASSET_NAME}.conf ]; then
  echo "Existing assetchain config file found, deleting it so new one can be created on startup."
  rm /home/komodo/.komodo/${ASSET_NAME}/${ASSET_NAME}.conf
fi

if [ ! -d /home/komodo/.komodo/${ASSET_NAME} ];then
  mkdir -p /home/komodo/.komodo/${ASSET_NAME}
fi

if [ ! -d /home/komodo/stats/${ASSET_NAME}/stats ];then
  mkdir -p /home/komodo/stats/${ASSET_NAME}/stats
fi

exec "$@"
