#!/bin/bash

PROJ_HOME=$(pwd)/..

kubectl --kubeconfig=${PROJ_HOME}/admin.config -n kubernetes-dashboard describe secret $(kubectl --kubeconfig=${PROJ_HOME}/admin.config -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

echo GOTO : 'https://localhost:8443/#/login'

kubectl --kubeconfig=${PROJ_HOME}/admin.config port-forward  \
     $(kubectl --kubeconfig=${PROJ_HOME}/admin.config get pods -l k8s-app=kubernetes-dashboard -o jsonpath="{.items[0].metadata.name}" -n kubernetes-dashboard) \
     --address 0.0.0.0 8443:8443 \
     -n kubernetes-dashboard
    