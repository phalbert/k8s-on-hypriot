#!/bin/sh

kubectl -n logging delete configmap promtail
kubectl -n logging create configmap promtail --from-file=promtail/
kubectl -n logging apply -f promtail.yaml
kubectl -n logging delete pod -lk8s-app=promtail
