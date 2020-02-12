# Kubernetes on with Vagrant, Virtualox and Centos7

Flannel on Vagrant, Flanel needs to use the host-only adapter eth1.
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/#default-nic-when-using-flannel-as-the-pod-network-in-vagrant

kubectl patch daemonset kube-flannel-ds-amd64 -n kube-system \
  --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/3", "value": "--iface=eth1"}]'

https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/

## Dashboard Portforwarding
kubectl --kubeconfig=admin.config port-forward  \
     $(kubectl --kubeconfig=admin.config get pods -l k8s-app=kubernetes-dashboard -o jsonpath="{.items[0].metadata.name}" -n kubernetes-dashboard) \
     --address 127.0.0.1 8443:8443 \
     -n kubernetes-dashboard

## HTTP ingress
kubectl -n kubernetes-dashboard apply -f - <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: frontend
spec:
  rules:
  - host: frontend.192.168.20.10.xip.io
    http:
      paths:
      - backend:
          serviceName: frontend
          servicePort: 80
        path: /
EOF

## HTTPS ingress
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=192.168.20.10.nip.io"
kubectl --namespace default create secret tls tls-secret --cert=tls.crt --key=tls.key

kubectl -n default apply -f - <<EOF
kind: Ingress
apiVersion: extensions/v1beta1
metadata:
  name: frontend
  namespace: default
spec:
  tls:
    - hosts:
        - frontend.192.168.20.10.nip.io
      secretName: tls-secret
  rules:
    - host: frontend.192.168.20.10.nip.io
      http:
        paths:
          - path: /
            backend:
              serviceName: frontend
              servicePort: 80
EOF


ip route list
ip route del default
nmcli device modify eth0 ipv4.method disable
nmcli device modify eth0 ipv6.method ignore
nmcli con modify 'System eth0' ipv4.never-default yes
nmcli con mod 'System eth0' connection.autoconnect no
ip route list


   21  ip route del default
   22  ip route add default via 192.168.20.1 dev eth1
   23  ip route list
   24  nmcli device modify eth0 ipv4.method disable
   25  ip route list
   26  nmcli device modify eth0 ipv4.method ignore
   27  nmcli device modify eth0 ipv6.method ignore
   28  ip route list
   29  reboot
   30  ip route list
   31  ip route del default
   32  ip route add default via 192.168.20.1 dev eth1
   33  ip route list
   34  nmcli device modify eth0 ipv4.method disable
   35  nmcli device modify eth0 ipv6.method ignore
   36  ip route list
   37  reboot
   38  ip route list
   39  ip route del default
   40  ip route list
   41  nmcli device modify eth0 ipv4.method disable
   42  nmcli device modify eth0 ipv6.method ignore
   43  ip route list
   44  ip route add default via 192.168.20.1 dev eth1
   45  ip route list
   46  cd /etc/sysconfig/network-scripts/
   47  ll
   48  cat ifcfg-eth0
   49  nmcli con mod eth0 connection.autoconnect no
   50  nmcli list con
   51  nmcli con list
   52  nmcli con
   53  nmcli con mod 'System eth0' connection.autoconnect no
   54  cat ifcfg-eth0
   55  ip route list
   56  nmcli con mod 'System eth0'
   57  nmcli con modify eth0 ipv4.never-default yes
   58  nmcli con modify 'Systemeth0' ipv4.never-default yes
   59  nmcli con modify 'System eth0' ipv4.never-default yes
   60  cat ifcfg-eth0