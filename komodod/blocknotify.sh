#!/bin/bash
HEIGHT=$(./getblockcount)
echo $HEIGHT > height

if [ "$HEIGHT" = "3" ]
  then
    ./importprivkey
    ./startMM
fi

if [ "$HEIGHT" = "5" ]
  then
    TXID=$(./sendfunds)
    echo "TXID=$TXID" > TXID
fi

if [ "$HEIGHT" = "8" ]
  then
   ./TxBlast
fi
