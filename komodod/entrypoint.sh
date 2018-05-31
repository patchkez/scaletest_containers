#!/bin/bash

KOMODO_HOME="/home/komodo"

if [ -n "${ASSET_NAME}" -a -n "${ASSET_RPC_PORT}" ];then

    cat > ${KOMODO_HOME}/confd/conf.d/assetchain.toml <<EOF
[template]
src = "assetchain.conf.tmpl"
dest = "/home/komodo/.komodo/${ASSET_NAME}/${ASSET_NAME}.conf"
keys = [
    "ASSET_RPC_USER",
    "ASSET_RPC_PASSWORD",
    "ASSET_BIND",
    "ASSET_RPC_BIND",
    "ASSET_RPC_ALLOWIP",
    "ASSET_RPC_WORKQUEUE",
    "ASSET_RPC_PORT"
    ]
EOF

    cat > ${KOMODO_HOME}/confd/templates/assetchain.conf.tmpl << EOF
rpcuser={{ or (getenv "ASSET_RPC_USER") "assetrpc" }}
rpcpassword={{ or (getenv "ASSET_RPC_PASSWORD") "assetrpcpassword" }}
server=1
txindex=1
bind={{ or (getenv "ASSET_BIND") "127.0.0.1" }}
rpcbind={{ or (getenv "ASSET_RPC_BIND") "127.0.0.1" }}
rpcallowip={{ or (getenv "ASSET_RPC_ALLOWIP") "0.0.0.0" }}
rpcworkqueue={{ or (getenv "ASSET_RPC_WORKQUEUE") "64" }}
rpcport={{ (getenv "ASSET_RPC_PORT" ) }}
EOF

elif [ -f /home/komodo/.komodo/${ASSET_NAME}/${ASSET_NAME}.conf ]; then
  echo "Existing assetchain config file found, deleting it so new one can be created on startup."
  rm /home/komodo/.komodo/${ASSET_NAME}/${ASSET_NAME}.conf
fi

if [ ! -d /home/komodo/.komodo/${ASSET_NAME} ];then
  mkdir -p /home/komodo/.komodo/${ASSET_NAME}
fi

if [ ! -d /home/komodo/stats/${ASSET_NAME}/stats ];then
  mkdir -p /home/komodo/stats/${ASSET_NAME}/stats
fi

confd -confdir ${KOMODO_HOME}/confd -onetime -backend env

exec "$@"
