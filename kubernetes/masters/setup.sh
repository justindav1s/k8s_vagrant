#!/bin/bash

echo -e "\n\n*** Configuring Masters ....."

PROJ_HOME=$(pwd)/../..

ssh root@192.168.20.11 "kubeadm init --apiserver-advertise-address=192.168.20.11 --pod-network-cidr=10.244.0.0/16"
ssh root@192.168.20.11 "systemctl status kubectl"
ssh root@192.168.20.11 "sed -i.bak 's/KUBELET_EXTRA_ARGS/KUBELET_EXTRA_ARGS --node-ip=192.168.20.11/' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf"
ssh root@192.168.20.11 "cat /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf"
ssh root@192.168.20.11 "systemctl daemon-reload"
ssh root@192.168.20.11 "systemctl restart kubelet"
ssh root@192.168.20.11 "systemctl status kubelet"

ssh root@192.168.20.11 'mkdir -p $HOME/.kube'
ssh root@192.168.20.11 'cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
ssh root@192.168.20.11 'chown $(id -u):$(id -g) $HOME/.kube/config'

echo running kubectl on master
ssh root@192.168.20.11 'kubectl get nodes'
ssh root@192.168.20.11 'kubectl get pods --all-namespaces'

echo gettting admin credentials
scp root@192.168.20.11:/root/.kube/config ${PROJ_HOME}/admin.config
ls -ltr ${PROJ_HOME}/admin.config

echo running kubectl on here
kubectl --kubeconfig=${PROJ_HOME}/admin.config get nodes
kubectl --kubeconfig=${PROJ_HOME}/admin.config get pods --all-namespaces

echo install flannel
kubectl --kubeconfig=${PROJ_HOME}/admin.config apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo waiting for flannel to come up
for i in {1..7}; do 
    kubectl --kubeconfig=${PROJ_HOME}/admin.config get nodes -o wide
    kubectl --kubeconfig=${PROJ_HOME}/admin.config get pods --all-namespaces
    sleep 7
done
