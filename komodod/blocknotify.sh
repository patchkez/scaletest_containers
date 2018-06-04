#!/bin/bash
amount=$AMOUNT          #Amount to send to blast script
passphrase=$PASSPHRASE  #Passphrase to give marketmaker
address=$ADDRESS        #Address of the above passphrase
privkey=$PRIVATE_KEY    #Private key of miners pubkey
chain=$ASSET_NAME       #Asset chain name
rpcport=$ASSET_RPC_PORT #rpc port of this assetchain
source start            #start file, starts as start=0
source startblockheight #block height start=1 was fetched.starts as 0.

HEIGHT=$(komodo-cli -ac_name=$chain getblockcount) #current block height
STATS_FILE="/home/komodo/stats/${ASSET_NAME}/stats/${ASSET_NAME}_stats.txt"

#do the stats first if this is a stats node
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

#fetch the start variable, if we have a start block height then the blaster will start
if [ $start -eq 0 ] && [ $startblockheight -eq 0 ]; then
  curl $STARTURL -o star
  sleep 1
  exit
elif [ $start -eq 1 ]; then
  echo "startblockheight=$HEIGHT" > startblockheight
  sleep 1
  exit
fi

if [ $HEIGHT -eq $(( $startblockheight +3 )) ]
  then
    komodo-cli -ac_name=$chain importprivkey $privkey
    ./marketmaker "{\"gui\":\"nogui\",\"client\":1, \"userhome\":\"/${HOME#"/"}\", \"passphrase\":\""default"\", \"coins\":[{\"coin\":\"$chain\",\"asset\":\"$chain\",\"rpcport\":$rpcport}]}" &
fi

if [ $HEIGHT -eq $(( $startblockheight +5 )) ] && [ $TXBLASTER -eq 1 ]
  then
    TXID=$(komodo-cli -ac_name=$chain sendtoaddress $address $amount)
    echo "TXID=$TXID" > TXID
fi

if [ $HEIGHT -eq $(( $startblockheight +7 )) ] && [ $TXBLASTER -eq 2 ]
  then
    TXID=$(komodo-cli -ac_name=$chain sendtoaddress $address $amount)
    echo "TXID=$TXID" > TXID
fi

if [ $HEIGHT -eq $(( $startblockheight +10 )) ] && [[ $TXBLASTER -eq 1 || $TXBLASTER -eq 2 ]]
  then
    #Start the blaster, $1 specifies amountof payments,options are 1 and 100.
    ./TxBlast 1 &
fi

if [ $HEIGHT -eq $(( $startblockheight +80 )) ] && [ $TXBLASTER -eq 1 ]
  then
    TXID=$(komodo-cli -ac_name=$chain sendtoaddress $address $amount)
    echo "TXID=$TXID" > TXID
fi

if [ $HEIGHT -eq $(( $startblockheight +85 )) ] && [ $TXBLASTER == 1 ]
  then
    #Start the blaster, $1 specifies amountof payments,options are 1 and 100.
    ./TxBlast 100 &
fi
