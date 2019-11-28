#!/bin/bash

set -e

#kubectl -n vault port-forward vault-0 8200:8200

# Variables
#export VAULT_TOKEN=""
#export PASSWORD=""

export VAULT_ADDR="http://localhost:8200"

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

vault write auth/userpass/users/stephen password="$PASSWORD" policies="admin"
vault token create -policy=metrics -display-name=prometheus -no-default-policy

rm -f $VAULT_ADMIN_POLICY_FILE >/dev/null
rm -f $VAULT_METRICS_POLICY_FILE >/dev/null
