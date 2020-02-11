#!/bin/bash

rm -rf original-ks.cfg

# SSH config
mkdir ~/.ssh
cd ~/.ssh

cp ~vagrant/.ssh/id_rsa .
cp ~vagrant/.ssh/id_rsa.pub .
cat ~vagrant/.ssh/authorized_keys ~vagrant/.ssh/id_rsa.pub > ~vagrant/.ssh/authorized_keys.cat
cp ~vagrant/.ssh/authorized_keys.cat ~vagrant/.ssh/authorized_keys
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

systemctl disable firewalld
systemctl softwareupdate firewalld

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

echo Swiching Off Swap.
cat /etc/fstab | sed '/ swap / s/^\(.*\)$/#\1/g' > /etc/fstab.bak
mv -f /etc/fstab.bak /etc/fstab
cat /etc/fstab
swapoff -a

cat >>/etc/sysctl.d/kubernetes.conf<< EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

yum install -y kubeadm kubelet kubectl

yum install -y -q yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y -q docker-ce

systemctl enable docker

systemctl enable kubelet

nmcli con mod 'System eth0' ipv4.dns 192.168.20.10
nmcli con mod 'System eth0' ipv4.ignore-auto-dns yes
nmcli con down 'System eth0' && nmcli con up 'System eth0'

touch DONE
echo DONE. Rebooting.

reboot