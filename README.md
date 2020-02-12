# Kubernetes on with Vagrant, Virtualox and Centos7

This repo deploys kubernetes into a cloud composed of Vagrant, VirtualBox and Centos 7.

As currently configured it spins up 7 vms, a load-balancer, 3 controllers and 3 workers. As currently configured it uses 36GB of RAM, but could be confiured to use much less. See the settings in [cluster/vagrantFile](cluster/vagrantFile).

   * [bin](bin) : scripts that start the cloud and deploy Kubernetes
     * cluster.sh [up|halt|destroy .....] : spin up the cloud
     * deploy.sh : deploy kubernetes
     * snapshot_create.sh : create a vitrulbox snapshot
     * dashboard port-forwarding
   * [cluster](cluster/) : contains vagrant and script resources to to spin up the VM cluster, with static IP addresses
      * 192.168.20.10 : haproxy load-balancer and dnsmasq DNS server
      * 192.168.20.[11-13] : kubernetes masters hosting the API
      * 192.168.20.[21-23] : kubernetes workers that hosts pods with cri-o
   * [cluster/init_scripts](cluster/init_scripts) : scripts that initialise each VM appropriately at start up
   * [kubernetes/masters](kubernetes/masters) : scripts to setup and check the status of the kubernetes control plane
     * Flanel deploy
   * [kubernetes/workers](kubernetes/workers) : scripts to setup and check the status of the kubernetes workers
     * dashboard deploy
   * [lb](lb) : script to check the status of the loadbalancer for the kubernetes API
   * [ingress](ingress) : contains script to configure nginx ingress


## Flannel on Vagrant

Flannel needs to use the host-only adapter eth1.

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/#default-nic-when-using-flannel-as-the-pod-network-in-vagrant

```
kubectl patch daemonset kube-flannel-ds-amd64 -n kube-system \
  --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/3", "value": "--iface=eth1"}]'
```

https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/

## Dashboard Portforwarding

```
kubectl --kubeconfig=admin.config port-forward  \
     $(kubectl --kubeconfig=admin.config get pods -l k8s-app=kubernetes-dashboard -o jsonpath="{.items[0].metadata.name}" -n kubernetes-dashboard) \
     --address 127.0.0.1 8443:8443 \
     -n kubernetes-dashboard
```


## HTTP ingress

```
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
```

## HTTPS ingress

```
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
```