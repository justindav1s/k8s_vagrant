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

touch DONE
echo DONE. Rebooting

reboot