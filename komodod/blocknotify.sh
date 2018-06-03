#!/bin/bash
amount=$AMOUNT          #Amount to send to blast script
passphrase=$PASSPHRASE  #Passphrase to give marketmaker
address=$ADDRESS        #Address of the above passphrase
privkey=$PRIVATE_KEY    #Private key of miners pubkey
chain=$ASSET_NAME       #Asset chain name
rpcport=$ASSET_RPC_PORT #rpc port of this assetchain


STATS_FILE="/home/komodo/stats/${ASSET_NAME}/stats/${ASSET_NAME}_stats.txt"

HEIGHT=$(komodo-cli -ac_name=$chain getblockcount) #current block height

if [ $HEIGHT -eq 3 ]
  then
    komodo-cli -ac_name=$chain importprivkey $privkey
    ./marketmaker "{\"gui\":\"nogui\",\"client\":1, \"userhome\":\"/${HOME#"/"}\", \"passphrase\":\""default"\", \"coins\":[{\"coin\":\"$chain\",\"asset\":\"$chain\",\"rpcport\":$rpcport}]}" &
fi

if [ $HEIGHT -eq 5 ] && [ $TXBLASTER -eq 1 ]
  then
    TXID=$(komodo-cli -ac_name=$chain sendtoaddress $address $amount)
    echo "TXID=$TXID" > TXID
fi

if [ $HEIGHT -eq 7 ] && [ $TXBLASTER -eq 2 ]
  then
    TXID=$(komodo-cli -ac_name=$chain sendtoaddress $address $amount)
    echo "TXID=$TXID" > TXID
fi

if [ $HEIGHT == 10 ] && [[ $TXBLASTER == 1 || $TXBLASTER == 2 ]]
  then
    #Start the blaster, $1 specifies amountof payments,options are 1 and 100.
    ./TxBlast 1 &
fi

if [ $HEIGHT -eq 65 ] && [ $TXBLASTER -eq 1 ]
  then
    TXID=$(komodo-cli -ac_name=$chain sendtoaddress $address $amount)
    echo "TXID=$TXID" > TXID
fi

if [ $HEIGHT -eq 70 ] && [ $TXBLASTER -eq 2 ]
  then
    TXID=$(komodo-cli -ac_name=$chain sendtoaddress $address $amount)
    echo "TXID=$TXID" > TXID
fi

if [ $HEIGHT == 75 ] && [[ $TXBLASTER == 1 || $TXBLASTER == 2 ]]
  then
    #Start the blaster, $1 specifies amountof payments,options are 1 and 100.
    ./TxBlast 100 &
fi

if [ $STATS -eq 1 ]
  then
    block=$(komodo-cli -ac_name=$chain getblock $HEIGHT)
    mempool=$(komodo-cli -ac_name=$chain getmempoolinfo)
    blockinfo=$(echo $block | jq '{size, height, time}')
    totaltx=$(echo $block | jq '.tx | length')
    mempooltx=$(echo $mempool | jq -r .size)
    mempoolMB=$(( $(echo $mempool | jq -r .bytes) / 1000000 ))
    RESULT=$(echo $blockinfo | jq --argjson mempooltx $mempooltx --argjson mempoolMB $mempoolMB --argjson totaltx $totaltx --arg chain $chain '. += {"totaltx":$totaltx, "ac":$chain, "mempooltx":$mempooltx, "mempoolMB":$mempoolMB}')
    echo $RESULT >> ${STATS_FILE}
    curl \
    --verbose \
    --request OPTIONS \
    ${BLOCKNOTIFYURL} \
    --header 'Origin: http://localhost:8000' \
    --header 'Access-Control-Request-Headers: Origin, Accept, Content-Type' \
    --header 'Access-Control-Request-Method: POST'
    sleep 2
    curl \
    --verbose \
    --header "Origin: http://localhost:8000" \
    --request POST \
    --data "${RESULT}" \
    ${BLOCKNOTIFYURL}
fi
