#!/bin/sh

kubectl -n logging delete configmap promtail
kubectl -n logging create configmap promtail --from-file=promtail-cnf.yaml
kubectl -n logging delete pod -lk8s-app=promtail
