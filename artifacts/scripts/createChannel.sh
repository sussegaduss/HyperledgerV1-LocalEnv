#!/bin/bash

CHANNEL_NAME="$1"
: ${CHANNEL_NAME:="mychannel"}
: ${TIMEOUT:="60"}
COUNTER=0
MAX_RETRY=5
ORDERER_CA=/etc/hyperledger/crypto/ordererOrganizations/ordererOrg1/orderers/ordererOrg1orderer1/cacerts/ordererOrg1-cert.pem

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

	CORE_PEER_ADDRESS=peer$1:7051
	CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/tls/peer$1/ca-cert.pem
	if [ $1 -eq 0  ] ; then
		CORE_PEER_LOCALMSPID="Org1MSP"
		CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peerOrganizations/peerOrg1/peers/peerOrg1Peer1
	fi

	if [ $1 -eq 1  ] ; then
		CORE_PEER_LOCALMSPID="Org1MSP"
		CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peerOrganizations/peerOrg1/peers/peerOrg1Peer2
	fi

	if [ $1 -eq 2] ; then
		CORE_PEER_LOCALMSPID="Org2MSP"
		CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peerOrganizations/peerOrg2/peers/peerOrg2Peer1
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer/peer$1/localMspConfig/cacerts/peerOrg1.pem
	fi

	if [ $1 -eq 3] ; then
		CORE_PEER_LOCALMSPID="Org2MSP"
		CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peerOrganizations/peerOrg2/peers/peerOrg2Peer2
	fi

	env |grep CORE
}

createChannel() {
	CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/ordererOrganizations/ordererOrg1/msp

	CORE_PEER_LOCALMSPID="OrdererMSP"

    if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
		peer channel create -o orderer0:7050 -c $CHANNEL_NAME -f /etc/hyperledger/configtx/channel.tx >&log.txt
	else
		peer channel create -o orderer0:7050 -c $CHANNEL_NAME -f /etc/hyperledger/configtx/channel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
	fi
	res=$?
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel \"$CHANNEL_NAME\" is created successfully ===================== "
	echo
}

## Create channel
createChannel
