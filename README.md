# k8s_vagrant
k8s_vagrant


kubectl --kubeconfig=admin.config port-forward  \
     $(kubectl --kubeconfig=admin.config get pods -l k8s-app=kubernetes-dashboard -o jsonpath="{.items[0].metadata.name}" -n kubernetes-dashboard) \
     --address 127.0.0.1 8443:8443 \
     -n kubernetes-dashboard