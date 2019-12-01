#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)
source "$REPO_ROOT/setup/.env"

kubectl -n infra create secret generic linode-dynamic-dns --from-literal="token=$LINODE_TOKEN"

AUTHSTRING=$(htpasswd -nb $AUTH_USERNAME $AUTH_PASSWORD)
kubectl -n infra create secret generic dashboards-auth --from-literal="auth=$AUTHSTRING"
kubectl -n logging create secret generic dashboards-auth --from-literal="auth=$AUTHSTRING"
kubectl -n monitoring create secret generic dashboards-auth --from-literal="auth=$AUTHSTRING"
kubectl -n apps create secret generic dashboards-auth --from-literal="auth=$AUTHSTRING"
kubectl -n vault create secret generic dashboards-auth --from-literal="auth=$AUTHSTRING"

kubectl -n vault delete secret vault-unseal-keys || true
kubectl -n vault create secret generic vault-unseal-keys --from-literal="VAULT_UNSEAL_KEY_1=$VAULT_UNSEAL_KEY_1" \
                                                         --from-literal="VAULT_UNSEAL_KEY_2=$VAULT_UNSEAL_KEY_2" \
                                                         --from-literal="VAULT_UNSEAL_KEY_3=$VAULT_UNSEAL_KEY_3" \
                                                         --from-literal="VAULT_UNSEAL_KEY_4=$VAULT_UNSEAL_KEY_4" \
                                                         --from-literal="VAULT_UNSEAL_KEY_5=$VAULT_UNSEAL_KEY_5"

kubectl -n flux create secret generic fluxcloud --from-literal="slack_url=$SLACK_URL"
kubectl -n monitoring create secret generic alertmanager --from-literal="slack_url=$SLACK_URL"
