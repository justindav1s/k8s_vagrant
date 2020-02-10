#!/bin/bash

PROJ_HOME=$(pwd)/../..

kubectl --kubeconfig=${PROJ_HOME}/admin.config get nodes