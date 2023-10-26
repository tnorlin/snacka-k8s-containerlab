
C1IP1=$(kubectl get ep --context $CLUSTER1 nginx -o json | jq -r '.subsets[].addresses[0].ip')
C1IP2=$(kubectl get ep --context $CLUSTER1 nginx -o json | jq -r '.subsets[].addresses[0].ip')
C2IP1=$(kubectl get ep --context $CLUSTER2 nginx -o json | jq -r '.subsets[].addresses[0].ip')
C2IP2=$(kubectl get ep --context $CLUSTER2 nginx -o json | jq -r '.subsets[].addresses[0].ip')
echo "C2dep -> C1IP1"
kubectl --context $CLUSTER2 exec deployments/curl -- curl -s -I --connect-timeout 2 ${C1IP1}
echo "C1dep -> C2IP2"
kubectl --context $CLUSTER1 exec deployments/curl -- curl -s -I --connect-timeout 2 ${C2IP2}
echo "C1dep -> 10.237.0.8:8080"
kubectl --context $CLUSTER1 exec deployments/curl -- curl 10.237.0.8:8080
echo "extbgp > 10.238.0.254"
docker exec -it clab-k8s-extbgp1 curl -s -I --connect-timeout 2 10.238.0.254
echo "intbgp > 10.238.0.254"
docker exec -it clab-k8s-intbgp1 curl -s -I --connect-timeout 2 10.238.0.254
echo "exthost > 10.238.0.254"
docker exec -it clab-k8s-exthost1 curl -s -I --connect-timeout 2 10.238.0.254
echo "clab1-k8s-worker > ${C1IP1}"
docker exec -it clab1-k8s-worker curl -s -I --connect-timeout 2 ${C1IP1}
echo "clab1-k8s-worker > ${C2IP1}"
docker exec -it clab1-k8s-worker curl -s -I --connect-timeout 2 ${C2IP1}
echo "clab2-k8s-worker > ${C1IP2}"
docker exec -it clab2-k8s-worker curl -s -I --connect-timeout 2 ${C1IP2}
echo "clab-k8s-inthost > ${C1IP2}"
docker exec -it clab-k8s-inthost1 curl -s -I --connect-timeout 2 ${C1IP2}
echo "clab-k8s-inthost > ${C2IP2}"
docker exec -it clab-k8s-inthost1 curl -s -I --connect-timeout 2 ${C2IP2}
echo "C1dep -> C1IP1"
kubectl --context $CLUSTER1 exec deployments/curl -- curl -s -I --connect-timeout 2 ${C1IP1}
echo "C2dep -> C2IP2"
kubectl --context $CLUSTER2 exec deployments/curl -- curl -s -I --connect-timeout 2 ${C2IP2}
