#!/bin/sh

kubectl -n infra delete configmap promtail
kubectl -n infra create configmap promtail --from-file=promtail/
kubectl -n infra apply -f promtail.yaml
kubectl -n infra delete pod -lk8s-app=promtail
