#!/bin/bash

set -e

kubectl -n vault port-forward svc/vault 8200:8200 >/dev/null 2>&1 &
VAULT_FWD_PID=$!
sleep 5

REPO_ROOT=$(git rev-parse --show-toplevel)
source "$REPO_ROOT/setup/.env"

# Variables
export VAULT_ADDR=$VAULT_ADDR
export VAULT_TOKEN=$VAULT_ROOT_TOKEN
ADMIN_USERNAME=$VAULT_ADMIN_USERNAME
ADMIN_PASSWORD=$VAULT_ADMIN_PASSWORD

vault audit enable file file_path=stdout
vault secrets enable -path=apps kv
vault auth enable approle
vault auth enable userpass

VAULT_ADMIN_POLICY_FILE="/tmp/vault-admin-policy.hcl"
VAULT_ADMIN_POLICY_NAME="admin"

cat >${VAULT_ADMIN_POLICY_FILE}<<EOF
path "*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}
EOF

vault policy write $VAULT_ADMIN_POLICY_NAME $VAULT_ADMIN_POLICY_FILE >/dev/null

echo -e "[ INFO ] New policy created/updated: $(vault policy list | grep ${VAULT_ADMIN_POLICY_NAME})"

VAULT_METRICS_POLICY_FILE="/tmp/vault-metrics-policy.hcl"
VAULT_METRICS_POLICY_NAME="metrics"
cat >${VAULT_METRICS_POLICY_FILE}<<EOF
path "sys/metrics*" {
  capabilities = ["read", "list"]
}
EOF

vault policy write $VAULT_METRICS_POLICY_NAME $VAULT_METRICS_POLICY_FILE >/dev/null
echo -e "[ INFO ] New policy created/updated: $(vault policy list | grep ${VAULT_METRICS_POLICY_NAME})"

vault write auth/userpass/users/$ADMIN_USERNAME password="$ADMIN_PASSWORD" policies="admin"
vault token create -policy=metrics -display-name=prometheus -no-default-policy

rm -f $VAULT_ADMIN_POLICY_FILE >/dev/null
rm -f $VAULT_METRICS_POLICY_FILE >/dev/null

kill $VAULT_FWD_PID