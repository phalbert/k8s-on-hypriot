#!/bin/bash

set -e

#kubectl -n vault port-forward vault-0 8200:8200

# Variables
#VAULT_TOKEN=""
#VAULT_ADDR=""
#VAULT_TOKEN=$(curl --slient  --data '{ "role_id": "68cee7b8-b8bb-ec1e-20b9-88d87a510833", "secret_id": "d33377fe-41b6-f54e-1063-b440301256b8" }' --request POST "${VAULT_ADDR}/v1/auth/approle/login")


#if [[ -z $1 ]]; then
#   echo "Password must be provided explicitly";
#   exit 1;
#else
#   PASSWORD=$1;
#fi

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

#curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET "$VAULT_ADDR/v1/sys/metrics?format=prometheus"

rm -f $VAULT_ADMIN_POLICY_FILE >/dev/null
rm -f $VAULT_METRICS_POLICY_FILE >/dev/null
