#!/bin/bash

PROJ_HOME=$(pwd)/..

# Setup Kubernetes master/controllers
cd ${PROJ_HOME}/kubernetes/masters
./setup.sh
sleep 10
./status.sh

# Setup Kubernetes workers
cd ${PROJ_HOME}/kubernetes/workers
./setup.sh
sleep 10
./status.sh

# Setup Ingress
cd ${PROJ_HOME}/ingress
./setup.sh
