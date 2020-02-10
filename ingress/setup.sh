#!/bin/bash


echo -e "\n\n*** Configuring Workers : Ingress ....."

TAG="v1.6.2"
REPO="https://raw.githubusercontent.com/nginxinc/kubernetes-ingress"
GITHUB="${REPO}/${TAG}/deployments"
NAMESPACE="nginx-ingress"

kubectl apply -f ${GITHUB}/common/ns-and-sa.yaml
kubectl apply -f ${GITHUB}/rbac/rbac.yaml
kubectl apply -f ${GITHUB}/common/default-server-secret.yaml
kubectl apply -f ${GITHUB}/common/nginx-config.yaml
kubectl apply -f ${GITHUB}/common/custom-resource-definitions.yaml
kubectl apply -f ${GITHUB}/daemon-set/nginx-ingress.yaml

for i in {1..5}; do 
    kubectl --kubeconfig=${PROJ_HOME}/admin.config get pods -o wide -n ${NAMESPACE}
    sleep 5
done
