#!/bin/bash

PROJ_HOME=$(pwd)/..

# Setup Kubernetes master/controllers
cd ${PROJ_HOME}/kubernetes/controllers
./setup.sh
./rbac.sh
sleep 10
./status.sh

# Setup haproxy loadbalancer
cd ${PROJ_HOME}/lb
./setup.sh
sleep 10
./status.sh
# sleep 10
# ./status.sh

# Setup Kubernetes workers
cd ${PROJ_HOME}/kubernetes/workers
./setup.sh
sleep 10
./status.sh
