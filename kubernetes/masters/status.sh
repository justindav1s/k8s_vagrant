#!/bin/bash

PROJ_HOME=$(pwd)/../..

for INTERNAL_IP in 192.168.20.11; do

echo -e "\n${INTERNAL_IP} - calling : kubectl get componentstatuses"

ssh -q root@${INTERNAL_IP} "kubectl get componentstatuses"

echo -e "\n${INTERNAL_IP} - calling healthz endpoint from master"
ssh -q root@${INTERNAL_IP} "curl -qsk -H \"Host: kubernetes.default.svc.cluster.local\" -i https://127.0.0.1:6443/healthz"
echo -e "\n\n"

echo -e "\n${INTERNAL_IP} - calling version endpoint from master"
ssh -q root@192.168.20.10 "curl -sk https://192.168.20.10:6443/version"

echo -e "\n${INTERNAL_IP} - calling version endpoint locally"
curl -sk https://192.168.20.10:6443/version

done  