#!/bin/bash

source ".env"

kubectl -n infra create secret generic linode-dynamic-dns --from-literal="token=$LINODE_TOKEN"

AUTHSTRING=$(htpasswd -nb $AUTH_USERNAME $AUTH_PASSWORD)

kubectl -n infra create secret generic dashboards-auth --from-literal="auth=$AUTHSTRING"
kubectl get secret dashboards-auth --namespace=infra --export -o yaml | kubectl apply --namespace=logging -f -
kubectl get secret dashboards-auth --namespace=infra --export -o yaml | kubectl apply --namespace=monitoring -f -
kubectl get secret dashboards-auth --namespace=infra --export -o yaml | kubectl apply --namespace=apps -f -
kubectl get secret dashboards-auth --namespace=infra --export -o yaml | kubectl apply --namespace=vault -f -