#!/bin/bash

# Install the required packages   
yum install haproxy dnsmasq -y

# SSH config
mkdir ~/.ssh
cd ~/.ssh

cp ~vagrant/.ssh/id_rsa .
cp ~vagrant/.ssh/id_rsa.pub .
cp ~vagrant/.ssh/authorized_keys .

cat <<EOF > ~/.ssh/config
Host 192.168.20.*
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF

chmod 600 id_rsa
chmod 600 authorized_keys
chmod 600 ~/.ssh/config

cd ~

# dnsmasq config
cat > /etc/dnsmasq.d/kube <<EOF
no-dhcp-interface=eth0
bogus-priv
domain=kube
expand-hosts
local=/kube/
domain-needed
no-resolv
no-poll
server=8.8.8.8
server=8.8.4.4
EOF

cat > /etc/hosts <<EOF

192.168.20.10   lb nfs
192.168.20.11   master1 etcd0
192.168.20.12   master2 etcd1
192.168.20.13   master3 etcd2
192.168.20.21   worker1
192.168.20.22   worker2
192.168.20.23   worker3
EOF

systemctl enable dnsmasq
systemctl start dnsmasq
systemctl status dnsmasq

systemctl disable firewalld
systemctl stop firewalld

sed 's/enforcing/disabled/' </etc/selinux/config >/etc/selinux/config.new
cp /etc/selinux/config.new /etc/selinux/config
rm -rf /etc/selinux/config.new

cat >>/etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubeadm kubelet kubectl

echo Swiching Off Swap.
cat /etc/fstab | sed '/ swap / s/^\(.*\)$/#\1/g' > /etc/fstab.bak
mv -f /etc/fstab.bak /etc/fstab
cat /etc/fstab
swapoff -a

mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy_cfg.original
cat > /etc/haproxy/haproxy.cfg << EOF
global

    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    stats socket /var/lib/haproxy/stats

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

listen stats
    bind :9000
    mode http
    stats enable
    stats uri /
    monitor-uri /healthz

frontend openshift-api-server
    bind *:6443
    default_backend openshift-api-server
    mode tcp
    option tcplog

backend openshift-api-server
    balance source
    mode tcp
    server master-1-api-router 192.168.20.11:6443 check
    server master-2-api-router 192.168.20.12:6443 check
    server master-3-api-router 192.168.10.33:6443 check
  
frontend ingress-http
    bind *:80
    default_backend ingress-http
    mode tcp
    option tcplog

backend ingress-http
    balance source
    mode tcp
    server worker-1-http-router 192.168.20.21:80 check
    server worker-2-http-router 192.168.20.22:80 check
    server worker-3-http-router 192.168.20.23:80 check
   
frontend ingress-https
    bind *:443
    default_backend ingress-https
    mode tcp
    option tcplog

backend ingress-https
    balance source
    mode tcp
    server worker-1-https-router 192.168.20.21:443 check
    server worker-2-https-router 192.168.20.22:443 check
    server worker-3-https-router 192.168.20.23:443 check
EOF

systemctl daemon-reload
systemctl enable haproxy
systemctl start haproxy

nmcli con mod 'System eth0' ipv4.dns 192.168.20.10
nmcli con mod 'System eth0' ipv4.ignore-auto-dns yes
nmcli con down 'System eth0' && nmcli con up 'System eth0'

echo DONE. Rebooting

reboot