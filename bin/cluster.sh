#!/bin/bash
#set -x

PROJ_HOME=$(pwd)/..

SERVERS="lb master1 worker1"
ACTION=$@

cd ${PROJ_HOME}/cluster

for SERVER in $SERVERS; do

    echo $ACTION : $SERVER
    rm -rf ${PROJ_HOME}/cluster/logs/$SERVER.out
    nohup vagrant $ACTION $SERVER > ${PROJ_HOME}/cluster/logs/$SERVER.out & 
    sleep 10

done
