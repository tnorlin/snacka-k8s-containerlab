### Some useful commands
CLUSTER1=kind-clab1-k8s
CLUSTER2=kind-clab2-k8s
export CLUSTER1 CLUSTER2

cilium config view | grep mesh-auth
cilium config set debug true

kubectl --context $CLUSTER1 -n kube-system exec ds/cilium -- cilium status
kubectl --context $CLUSTER2 -n kube-system exec ds/cilium -- cilium status

kubectl apply -f create-deploy.yaml

kubectl port-forward -n kube-system svc/hubble-relay 4245:80 &

kubectl exec deploy/curl -- curl -s http://nginx/
hubble observe -n default

kubectl --context $CLUSTER1 exec deployments/curl -- curl 10.237.0.8:8080

kubectl patch cnp allow-curl --type='json'         -p='[{"op": "replace", "path": "/spec/ingress/0/authentication", "value": {"mode": "required"} }]'


kubectl exec -n cilium-spire spire-server-0 -c spire-server -- /opt/spire/bin/spire-server healthcheck

kubectl exec -n cilium-spire spire-server-0 -c spire-server -- /opt/spire/bin/spire-server agent list

kubectl exec -n cilium-spire spire-server-0 -c spire-server -- /opt/spire/bin/spire-server entry show -parentID spiffe://spiffe.cilium/ns/cilium-spire/sa/spire-agent


kubectl exec -n cilium-spire spire-server-0 -c spire-server -- /opt/spire/bin/spire-server entry show -spiffeID spiffe://spiffe.cilium/identity/$(kubectl get cep -l app=nginx -o=jsonpath='{.items[0].status.identity.id}')


kubectl exec -n cilium-spire spire-server-0 -c spire-server -- /opt/spire/bin/spire-server entry show -selector cilium:mutual-auth


kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath="{.items[?(@.spec.nodeName==\"$(kubectl -n default get pods -l app=nginx -o jsonpath="{.items[].spec.nodeName}")\")].metadata.name}"; echo
