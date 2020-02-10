#!/bin/bash

PROJ_HOME=$(pwd)/../..

kubectl --kubeconfig=${PROJ_HOME}/admin.config get nodes -o wide
kubectl --kubeconfig=${PROJ_HOME}/admin.config get pods -o wide --all-namespaces