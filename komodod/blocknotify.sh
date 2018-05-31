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

if [ "$HEIGHT" = "8" ] && [ "$TXBLASTER" = "1" ]
  then
    ./TxBlast
fi

if [ "$STATS" = "1" ]
  then
    block=$(komodo-cli -ac_name=$chain getblock $HEIGHT)
    testing=$(echo $block | jq '{size, height, time}')
    totaltx=$(echo $block | jq '.tx | length')
    JSON=$(echo $testing | jq --arg totaltx $totaltx --arg chain $chain '. += {"totaltx":$totaltx, "ac":$chain}')
    echo $JSON >> ~/stats/stats.txt
    RESULT=$(echo $JSON | sed 's/\"/\\\"/g')
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
