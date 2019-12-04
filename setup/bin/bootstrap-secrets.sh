#!/bin/bash

REPO_ROOT=$(git rev-parse --show-toplevel)
source "$REPO_ROOT/setup/.env"

kubectl -n infra create secret generic linode-dynamic-dns --from-literal="token=$LINODE_TOKEN"

kubectl -n flux create secret generic fluxcloud --from-literal="slack_url=$SLACK_URL"
kubectl -n monitoring create secret generic alertmanager --from-literal="slack_url=$SLACK_URL"

kubectl -n infra create secret generic minio --from-literal="accesskey=$MINIO_ACCESS_KEY" \
                                             --from-literal="secretkey=$MINIO_SECRET_KEY"

kubectl -n velero create secret generic velero --from-literal="accesskey=$MINIO_ACCESS_KEY" \
                                               --from-literal="secretkey=$MINIO_SECRET_KEY"

kubectl -n infra create secret generic traefik-forward-auth-secrets --from-literal="CLIENT_ID=$OAUTH_CLIENT_ID" \
                                                                    --from-literal="CLIENT_SECRET=$OAUTH_CLIENT_SECRET" \
                                                                    --from-literal="SECRET=$OAUTH_SECRET"