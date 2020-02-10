#!/bin/bash

PROJ_HOME=$(pwd)/../..

COMMAND=$(ssh root@192.168.20.11 'kubeadm token create --print-join-command | grep kubeadm')

echo COMMAND : $COMMAND

ssh root@192.168.20.21 $COMMAND

for i in {1..5}; do 
    kubectl --kubeconfig=${PROJ_HOME}/admin.config get nodes
    sleep 5
done

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml

for i in {1..5}; do 
    kubectl get pods -n kubernetes-dashboard
    sleep 7
done

kubectl apply -f https://raw.githubusercontent.com/justindav1s/k8s_vagrant/master/dashboard/admin_user.yaml

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
