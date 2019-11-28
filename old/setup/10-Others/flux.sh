#!/bin/sh

kubectl create namespace flux
helm repo add fluxcd https://charts.fluxcd.io
helm upgrade --install flux --values ./flux-values.yaml --namespace flux fluxcd/flux

kubectl -n flux logs deployment/flux | grep identity.pub | cut -d '"' -f2