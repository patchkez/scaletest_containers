#!/bin/bash
amount=$AMOUNT          #Amount to send to blast script

passphrase=$PASSPHRASE  #Passphrase to give marketmaker
address=$ADDRESS        #Address of the above passphrase

privkey=$PRIVATE_KEY    #Private key of miners pubkey

chain=$ASSET_NAME       #Asset chain name
rpcport=$ASSET_RPC_PORT #rpc port of this assetchain

HEIGHT=$(komodo-cli -ac_name=$chain getblockcount) #current block height

if [ "$HEIGHT" = "3" ]
  then
    komodo-cli -ac_name=$chain importprivkey $privkey
    ./marketmaker "{\"gui\":\"nogui\",\"client\":1, \"userhome\":\"/${HOME#"/"}\", \"passphrase\":\""default"\", \"coins\":[{\"coin\":\"$chain\",\"asset\":\"$chain\",\"rpcport\":$rpcport}]}"
fi

if [ "$HEIGHT" = "5" ]
  then
    TXID=$(komodo-cli -ac_name=$chain sendtoaddress $address $amount)
    echo "TXID=$TXID" > TXID
fi

if [ "$HEIGHT" = "8" ]
  then
   ./TxBlast
fi
