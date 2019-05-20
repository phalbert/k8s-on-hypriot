#!/bin/sh

kubectl -n infra delete configmap prometheus-config
kubectl -n infra create configmap prometheus-config --from-file=prometheus/
kubectl -n infra apply -f prometheus.yaml
kubectl -n infra delete pod -lapp=prometheus-server
