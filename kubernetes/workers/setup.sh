#!/bin/bash

COMMAND=$(ssh root@192.168.20.11 'kubeadm token create --print-join-command | grep kubeadm')

echo COMMAND : $COMMAND

ssh root@192.168.20.21 $COMMAND