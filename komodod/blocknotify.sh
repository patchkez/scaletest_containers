#!/bin/bash
amount=$AMOUNT          #Amount to send to blast script
passphrase=$PASSPHRASE  #Passphrase to give marketmaker
address=$ADDRESS        #Address of the above passphrase
privkey=$PRIVATE_KEY    #Private key of miners pubkey
chain=$ASSET_NAME       #Asset chain name
rpcport=$ASSET_RPC_PORT #rpc port of this assetchain
source start            #start file, starts as start=0
source startblockheight #block height starts as 0.

HEIGHT=$(komodo-cli -ac_name=$chain getblockcount) #current block height
STATS_FILE="/home/komodo/stats/${ASSET_NAME}/stats/${ASSET_NAME}_stats.txt"

#do the stats first if this is a stats node
if [ $STATS -eq 1 ]
  then
    block=$(komodo-cli -ac_name=$chain getblock $HEIGHT)
    blockinfo=$(echo $block | jq '{size, height, time}')
    totaltx=$(echo $block | jq '.tx | length')
    ttl=$(date -d '+15 minutes' +%s)
    RESULT=$(echo $blockinfo | jq --argjson ttl $ttl --argjson totaltx $totaltx --arg chain $chain '. += {"tx":$totaltx, "ac":$chain, "ttl":$ttl}')
    curl \
    --request OPTIONS \
    ${BLOCKNOTIFYURL} \
    --header 'Origin: http://localhost:8000' \
    --header 'Access-Control-Request-Headers: Origin, Accept, Content-Type' \
    --header 'Access-Control-Request-Method: POST'
    sleep 1
    resultJSON=$(curl \
    --header "Origin: http://localhost:8000" \
    --request POST \
    --data "${RESULT}" \
    ${BLOCKNOTIFYURL} )
    echo $resultJSON >> ${STATS_FILE}
fi

#Import the private key so we can send funds to the notaries and blasters.
if [ $HEIGHT -eq 3 ]
  then
    komodo-cli -ac_name=$chain importprivkey $privkey
fi

#fund notaries from mining node and open a SSH tunnel to host OS so we can connect notary node to it.
if [ $HEIGHT -eq 5 ] && [ $NOTARIZE != "false" ] && [ $STATS -eq 0 ]
  then
    komodo-cli -ac_name=$chain sendmany "" $NOTARYADDRESS
    ssh -f -N -L $ASSET_P2P_PORT:localhost:$ASSET_P2P_PORT $NOTARIZE -i ~/id_rsa &
fi

#fetch the start variable, if we have a start block height then the blaster will start otherwise exit the script now.
if [ $start -eq 0 ] && [ $startblockheight -eq 0 ]; then
 curl $STARTURL -o start
 sleep 1
 exit
elif [ $start -ne 0 ] && [ $startblockheight -eq 0 ]; then
 echo "startblockheight=$HEIGHT" > startblockheight
 sleep 1
 exit
fi

#if we are a TxBlaster then start a marketmaker
if [ $HEIGHT -eq $(( $startblockheight +2 )) ] && [[ $TXBLASTER -eq 1 ]]
  then
    ./marketmaker "{\"gui\":\"nogui\",\"client\":1, \"userhome\":\"/${HOME#"/"}\", \"passphrase\":\""default"\", \"coins\":[{\"coin\":\"$chain\",\"asset\":\"$chain\",\"rpcport\":$rpcport}], \"netid\":77}" &
fi

#Send some funds for the TxBlaster
if [ $HEIGHT -eq $(( $startblockheight +2 )) ] && [ $TXBLASTER -eq 1 ]
  then
    TXID=$(komodo-cli -ac_name=$chain sendtoaddress $address $amount)
    echo "TXID=$TXID" > TXID
fi

if [ $HEIGHT -eq $(( $startblockheight +5 )) ] && [[ $TXBLASTER -eq 1 ]]
  then
    #Start the blaster, $1 specifies amountof payments,options are 1 and 100.
    ./TxBlast 1 &
fi

#mining node is to pause mining when the blast is triggered, then resume at the start time.
if [ $HEIGHT -eq $(( $startblockheight +5 )) ] && [ $STATS -eq 0 ]
  then
    komodo-cli -ac_name=$chain setgenerate false
    now=$(( $(date +%s) -$(( $RANDOM % 60 + 1 )) ))
    sleep $(( $start -$now ))
    komodo-cli -ac_name=$chain setgenerate true 1
fi

#Send funds for the 100 payment test.
if [ $HEIGHT -eq $(( $startblockheight +36 )) ] && [ $TXBLASTER -eq 1 ]
  then
    TXID=$(komodo-cli -ac_name=$chain sendtoaddress $address $amount)
    echo "TXID=$TXID" > TXID
fi

#Start the 100 payment blast
if [ $HEIGHT -eq $(( $startblockheight +40 )) ] && [ $TXBLASTER -eq 1 ]
  then
    ./TxBlast 100 &
fi
