#!/bin/bash

. ./env.sh

for IP in $IPS; do

echo -e "\n$IP"
ssh -q root@$IP "ls"

done
