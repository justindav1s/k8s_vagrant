#!/bin/bash

for INTERNAL_IP in 192.168.20.11; do

echo "IP = ${INTERNAL_IP}"

ssh -q root@${INTERNAL_IP} "kubectl get componentstatuses"

ssh -q root@${INTERNAL_IP} "curl -ks -H \"Host: kubernetes.default.svc.cluster.local\" -i https://127.0.0.1:6443/healthz"
echo -e "\n\n"

done  