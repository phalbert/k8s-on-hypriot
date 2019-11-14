#!/bin/sh

kubectl -n monitoring delete configmap prometheus-config
kubectl -n monitoring create configmap prometheus-config --from-file=prometheus/
kubectl -n monitoring apply -f prometheus.yaml
kubectl -n monitoring delete pod -lapp=prometheus-server
