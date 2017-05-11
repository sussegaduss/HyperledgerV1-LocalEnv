#!/bin/bash

PEER_NODE="$1"
CHAINCODE_NAME="$2"
CHAINCODE_VERSION="$3"
CHAINCODE_ARGS="$4"

: ${CHANNEL_NAME:="mychannel"}
: ${TIMEOUT:="60"}
COUNTER=0
MAX_RETRY=5
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/orderer/localMspConfig/cacerts/ordererOrg0.pem

echo "Channel name : "$CHANNEL_NAME

verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
                echo "================== ERROR !!! FAILED to execute End-2-End Scenario =================="
		echo
   		exit 1
	fi
}

setGlobals () {

	CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer/peer$1/localMspConfig
	CORE_PEER_ADDRESS=peer$1:7051

	if [ $1 -eq 0 -o $1 -eq 1 ] ; then
		CORE_PEER_LOCALMSPID="Org0MSP"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer/peer$1/localMspConfig/cacerts/peerOrg0.pem
	else
		CORE_PEER_LOCALMSPID="Org1MSP"
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer/peer$1/localMspConfig/cacerts/peerOrg1.pem
	fi
	env |grep CORE
}


instantiateChaincode () {
	PEER="$1"
	CHAINCODE_ID="$2"
	VERSION=$3
	# ex '{"Args":["init","a","100","b","200"]}'
	ARGS="$4"

	setGlobals $PEER
        if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer chaincode instantiate -o orderer0:7050 -C $CHANNEL_NAME -n $CHANNEL_NAME -v $VERSION -c  '{"Args":["init","200"]}' -P "OR	('Org0MSP.member','Org1MSP.member')" >&log.txt
	else
		peer chaincode instantiate -o orderer0:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CHAINCODE_ID -v $VERSION -c  '{"Args":["init","200"]}' -P "OR	('Org0MSP.member','Org1MSP.member')" >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Chaincode instantiation on PEER$PEER on channel '$CHANNEL_NAME' failed"
	echo "===================== Chaincode Instantiation on PEER$PEER on channel '$CHANNEL_NAME' is successful ===================== "
	echo
}

#Instantiate chaincode 
echo "Instantiating chaincode:[$2] Version:[$3] on Peer $PEER_NODE ..."

instantiateChaincode $PEER_NODE $CHAINCODE_NAME $CHAINCODE_VERSION $CHAINCODE_ARGS

echo
echo "===================== All GOOD, execution completed ===================== "
echo
exit 0
