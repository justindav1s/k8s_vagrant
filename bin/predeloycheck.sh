#!/bin/bash

echo -e "c*** hecking master1 for docker status"
ssh root@192.168.20.11 "systemctl status docker"
echo -e "\n\n*** checking master1 for kublet status"
ssh root@192.168.20.11 "systemctl status kubelet"

echo -e "\n\n*** checking worker1 for docker status"
ssh root@192.168.20.21 "systemctl status docker"
echo -e "\n\n*** checking worker1 for kublet status"
ssh root@192.168.20.21 "systemctl status kubelet"
