#!/bin/bash


ssh root@192.168.20.11 "kubeadm init --apiserver-advertise-address=192.168.20.11 --pod-network-cidr=10.244.0.0/16"

ssh root@192.168.20.11 'mkdir -p $HOME/.kube'
ssh root@192.168.20.11 'cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
ssh root@192.168.20.11 'chown $(id -u):$(id -g) $HOME/.kube/config'

ssh root@192.168.20.11 'kubectl get nodes'
ssh root@192.168.20.11 'kubectl get pods --all-namespaces'

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

ssh root@192.168.20.11 'kubectl get pods --all-namespaces'
sleep 5
ssh root@192.168.20.11 'kubectl get pods --all-namespaces'