#!/bin/bash
bat --line-range 3: "${0}"
CLUSTER1=kind-clab1-k8s
CLUSTER2=kind-clab2-k8s
export CLUSTER1 CLUSTER2
cat ${CLUSTER1}_cluster.yaml
colordiff --suppress-common-lines -u ${CLUSTER1}_cluster.yaml ${CLUSTER2}_cluster.yaml

for i in {1..2}
do
    CLUSTER="CLUSTER$i"
    kind create cluster --config ${!CLUSTER}_cluster.yaml
done

# https://github.com/rpardini/docker-registry-proxy
for KIND_NAME in $(kind get clusters)
do
	SETUP_URL=http://docker-registry-proxy:3128/setup/systemd
        pids=""
        for NODE in $(kind get nodes --name "$KIND_NAME"); do
          docker exec "$NODE" sh -c "\
              curl $SETUP_URL \
              | sed s/docker\.service/containerd\.service/g \
              | sed '/Environment/ s/$/ \"NO_PROXY=127.0.0.0\/8,10.0.0.0\/8,172.16.0.0\/12,192.168.0.0\/16\"/' \
              | bash" & pids="$pids $!" # Configure every node in background
        done
        wait $pids
done
