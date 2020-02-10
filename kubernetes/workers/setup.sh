#!/bin/bash


echo -e "\n\n*** Configuring Workers ....."

PROJ_HOME=$(pwd)/../..

COMMAND=$(ssh root@192.168.20.11 'kubeadm token create --print-join-command | grep kubeadm')
echo COMMAND : $COMMAND

ssh root@192.168.20.21 $COMMAND

kubectl --kubeconfig=${PROJ_HOME}/admin.config get nodes

ssh root@192.168.20.21 "sed -i.bak 's/KUBELET_EXTRA_ARGS/KUBELET_EXTRA_ARGS --node-ip=192.168.20.21/' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf"
ssh root@192.168.20.21 "cat /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf"
ssh root@192.168.20.21 "systemctl daemon-reload"
ssh root@192.168.20.21 "systemctl restart kubelet"
ssh root@192.168.20.21 "systemctl status kubelet"

for i in {1..5}; do 
    kubectl --kubeconfig=${PROJ_HOME}/admin.config get nodes -o wide
    sleep 10
done


echo -e "\n\n*** Configuring Workers : Dashboard ....."
kubectl --kubeconfig=${PROJ_HOME}/admin.config apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml

for i in {1..5}; do 
    kubectl --kubeconfig=${PROJ_HOME}/admin.config get pods -n kubernetes-dashboard
    sleep 7
done

kubectl --kubeconfig=${PROJ_HOME}/admin.config apply -f admin_user.yaml

kubectl --kubeconfig=${PROJ_HOME}/admin.config -n kubernetes-dashboard describe secret $(kubectl --kubeconfig=${PROJ_HOME}/admin.config -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')


