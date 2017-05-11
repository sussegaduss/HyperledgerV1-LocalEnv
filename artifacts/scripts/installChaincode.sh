#!/bin/bash

PEER_NODE="$1"
CHAINCODE_NAME="$2"
CHAINCODE_VERSION="$3"
ORDERER_CA=/etc/hyperledger/crypto/ordererOrganizations/ordererOrg1/orderers/ordererOrg1orderer1/cacerts/ordererOrg1-cert.pem

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
	if [ $1 -eq 0 ] ; then
		CORE_PEER_LOCALMSPID="Org1MSP"
		CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peerOrganizations/peerOrg1/peers/peerOrg1Peer1
	fi

	if [ $1 -eq 1 ] ; then
		CORE_PEER_LOCALMSPID="Org1MSP"
		CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peerOrganizations/peerOrg1/peers/peerOrg1Peer2
	fi

	if [ $1 -eq 2 ] ; then
		CORE_PEER_LOCALMSPID="Org2MSP"
		CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peerOrganizations/peerOrg2/peers/peerOrg2Peer1
		CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peer/peer$1/localMspConfig/cacerts/peerOrg1.pem
	fi

	if [ $1 -eq 3 ] ; then
		CORE_PEER_LOCALMSPID="Org2MSP"
		CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peerOrganizations/peerOrg2/peers/peerOrg2Peer2
	fi

	env |grep CORE
}


installChaincode () {
	PEER=$1
	CHAINCODE_ID="$2"
	VERSION=$3

	setGlobals $PEER
	peer chaincode install -n $CHAINCODE_ID -v $VERSION -p github.com/hyperledger/fabric/peer/chaincode/$2 >&log.txt
	res=$?
	cat log.txt
        verifyResult $res "Chaincode[$CHAINCODE_ID] installation on remote peer PEER$PEER has Failed"
	echo "===================== Chaincode [$CHAINCODE_ID] is installed on remote peer PEER$PEER ===================== "
	echo
}


## Install chaincode on Peer 
installChaincode $PEER_NODE $CHAINCODE_NAME $CHAINCODE_VERSION

echo
echo "===================== All GOOD, execution completed ===================== "
echo
exit 0
