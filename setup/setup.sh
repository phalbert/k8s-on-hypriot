#!/bin/bash

set -e

REPO_ROOT=$(git rev-parse --show-toplevel)

message() {
    export CLI_MAGENTA=$(tput -Txterm-256color setaf 5)
    export CLI_BOLD=$(tput -Txterm-256color bold)
    export CLI_RESET=$(tput -Txterm-256color sgr0)

    printf "\n${CLI_BOLD}${CLI_MAGENTA}==========  %s  ==========${CLI_RESET}\n" "$@"
}

K3S_MASTER="master"
K3S_WORKERS_RPI="node-1 node-2 node-3"

kubectl taint nodes $K3S_MASTER node-role.kubernetes.io/master="":NoSchedule
for node in $K3S_WORKERS_RPI; do
    kubectl label node $node node-role.kubernetes.io/worker=worker
done

message "Installing Flux"
kubectl create namespace flux
helm repo add fluxcd https://charts.fluxcd.io
helm upgrade --install flux --values $REPO_ROOT/deployments/flux/flux/flux-values.yaml --namespace flux fluxcd/flux

FLUX_READY=1
while [ ${FLUX_READY} != 0 ]; do
    echo "Waiting for flux pod to be fully ready..."
    kubectl -n flux wait --for condition=available deployment/flux
    FLUX_READY="$?"
    sleep 5
done

kubectl -n flux logs deployment/flux | grep identity.pub | cut -d '"' -f2

#kubectl delete crd helmcharts.helm.cattle.io
#kubectl -n infra patch storageclass nfs-hdd -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
