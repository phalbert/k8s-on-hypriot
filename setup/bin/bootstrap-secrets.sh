#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)
source "$REPO_ROOT/setup/.env"

kubectl -n flux create secret generic fluxcloud --from-literal="slack_url=$SLACK_URL"
kubectl -n monitoring create secret generic alertmanager --from-literal="slack_url=$SLACK_URL"

kubectl -n infra create secret generic minio --from-literal="accesskey=$MINIO_ACCESS_KEY" \
                                             --from-literal="secretkey=$MINIO_SECRET_KEY"

kubectl -n velero create secret generic velero --from-literal="accesskey=$MINIO_ACCESS_KEY" \
                                               --from-literal="secretkey=$MINIO_SECRET_KEY"

kubectl -n infra create secret generic traefik-forward-auth-secrets --from-literal="CLIENT_ID=$OAUTH_CLIENT_ID" \
                                                                    --from-literal="CLIENT_SECRET=$OAUTH_CLIENT_SECRET" \
                                                                    --from-literal="SECRET=$OAUTH_SECRET"

kubectl -n vault delete secret vault-unseal-keys || true
kubectl -n vault create secret generic vault-unseal-keys --from-literal="VAULT_UNSEAL_KEY_1=$VAULT_UNSEAL_KEY_1" \
                                                         --from-literal="VAULT_UNSEAL_KEY_2=$VAULT_UNSEAL_KEY_2" \
                                                         --from-literal="VAULT_UNSEAL_KEY_3=$VAULT_UNSEAL_KEY_3" \
                                                         --from-literal="VAULT_UNSEAL_KEY_4=$VAULT_UNSEAL_KEY_4" \
                                                         --from-literal="VAULT_UNSEAL_KEY_5=$VAULT_UNSEAL_KEY_5"

#kubectl -n flux delete secret  fluxcloud
#kubectl -n monitoring delete  generic alertmanager
#kubectl -n infra delete secret  minio
#kubectl -n velero delete secret  velero