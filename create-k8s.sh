#!/bin/bash
bat kind-clab1-k8s_ippool.yaml kind-clab1-k8s_bgppolicy.yaml
colordiff --suppress-common-lines -u ${CLUSTER1}_ippool.yaml ${CLUSTER2}_ippool.yaml
colordiff --suppress-common-lines -u ${CLUSTER1}_bgppolicy.yaml ${CLUSTER2}_bgppolicy.yaml
bat --line-range 11:46 "${0}"
#    kubectl --context ${!CLUSTER} apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v0.7.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
#    kubectl --context ${!CLUSTER} apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v0.7.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
#    kubectl --context ${!CLUSTER} apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v0.7.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
#    kubectl --context ${!CLUSTER} apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v0.7.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
#    kubectl --context ${!CLUSTER} apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v0.7.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml
CLUSTER1=kind-clab1-k8s CLUSTER2=kind-clab2-k8s
y=8

for i in {1..2}
do
    CLUSTER="CLUSTER$i"
    echo ${!CLUSTER}

    K8S_API_PORT=$(kubectl cluster-info --context ${!CLUSTER} | head -1 |awk -F: '{print $3}')
    cilium install --context ${!CLUSTER} --version v1.14.3 \
	    --set cluster.id=${i} --set cluster.name=${!CLUSTER} \
	    --set k8sServiceHost=10.20.21.1 --set k8sServicePort=${K8S_API_PORT} \
	    --set ipam.mode=kubernetes \
	    --set image.pullPolicy=IfNotPresent \
	    --set bgpControlPlane.enabled=true \
	    --set externalIPs.enabled=true \
	    --set hubble.relay.enabled=true \
	    --set bgp.announce.loadbalancerIP=true \
	    --set requireIPv4PodCIDR=true \
	    --set tunnel=disabled \
	    --set autoDirectNodeRoutes=true --set routingMode=native  \
	    --set bpf.lbExternalClusterIP=true \
	    --set socketLB.hostNamespaceOnly=true \
	    --set bpf.masquerade=true \
	    --set ipv4NativeRoutingCIDR=10.$((y=y+2)).0.0/15 \
	    --set encryption.enabled=true --set encryption.type=wireguard \
	    --set encryption.nodeEncryption=true \
	    --set authentication.mutual.spire.enabled=true \
	    --set authentication.mutual.spire.install.enabled=true \
	    --set kubeProxyReplacement=true

    kubectl --context ${!CLUSTER} rollout status -n kube-system ds/cilium

    kubectl --context ${!CLUSTER} apply -f ${!CLUSTER}_ippool.yaml
    kubectl --context ${!CLUSTER} apply -f ${!CLUSTER}_bgppolicy.yaml
done
