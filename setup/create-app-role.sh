#!/bin/bash

# Usage:
# create.sh env_name app_name

# Examples:
# ./create.sh prod testapp

#kubectl -n vault port-forward vault-0 8200:8200

set -e

# Variables
export VAULT_TOKEN=""
export VAULT_ADDR="http://localhost:8200"


if [[ -z $1 ]]; then
   echo "Namespace must be provided explicitly";
   exit 1;
else
   KUBERNETES_NAMESPACE=$1;
fi

if [[ -z $2 ]];
   then echo "Application name must be provided explicitly";
   exit 1;
else
   KUBERNETES_APPLICATION=$2;
fi

#export VAULT_TOKEN
#export VAULT_ADDR

# Check connection to Vault
# vault status >/dev/null
# if [ $? -eq "0" ]; then
#     echo -e "[ INFO ] Vault is reachable on ${VAULT_HOST}:${VAULT_PORT}"
# elif [ $? == 1 ]; then
#     echo -e "[ ERROR ] Could not connect to Vault on ${VAULT_HOST}:${VAULT_PORT}"
#     exit 1
# elif [ $? -eq 2 ]; then
#     echo -e "[ ERROR ] Vault is sealed"
#     exit 1
# fi

#
# Create a policy for the service
#
VAULT_POLICY_NAME="${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION}"
VAULT_POLICY_FILE="/tmp/${VAULT_POLICY_NAME}.hcl"

# Check if a policy already exists
if [[ "$(vault policy list | grep ${VAULT_POLICY_NAME})" != "${VAULT_POLICY_NAME}" ]]; then
   echo -e "[ INFO ] Create a policy ${VAULT_POLICY_NAME}"
else
   echo -e "[ INFO ] Update a policy ${VAULT_POLICY_NAME}"
fi

cat >${VAULT_POLICY_FILE}<<EOF
path "apps/${KUBERNETES_NAMESPACE}/${KUBERNETES_APPLICATION}/*" {
   capabilities = ["read"]
}

path "apps/${KUBERNETES_NAMESPACE}/shared/*" {
   capabilities = ["read"]
}
EOF

vault policy write ${VAULT_POLICY_NAME} ${VAULT_POLICY_FILE} >/dev/null

echo -e "[ INFO ] New policy created/updated: $(vault policy list | grep ${VAULT_POLICY_NAME})"
rm -f ${VAULT_POLICY_FILE} >/dev/null

#
# Create a approle for the service
#

# Check if an approle already exists
# Debug: vault delete auth/approle/role/${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION}
if [[ "$(vault list auth/approle/role | grep ${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION})" == "${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION}" ]]; then
   echo -e "[ WARNING ] The AppRole ${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION} already exists. Abort"
   exit 0
else
   echo -e "[ INFO ] Create an AppRole for ${KUBERNETES_APPLICATION} in ${KUBERNETES_NAMESPACE}"
   vault write auth/approle/role/${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION} \
               policies=${VAULT_POLICY_NAME} \
               secret_id_ttl=0 \
               secret_id_num_uses=0 \
               token_num_uses=0 \
               token_ttl=1m \
               token_max_ttl=10m >/dev/null

   echo -e "[ INFO ] New ApRole created: $(vault list auth/approle/role | grep ${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION})"

   # Get roleid
   ROLE_ID=$(vault read auth/approle/role/${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION}/role-id | xargs | awk '{ print $6 }')

   echo -e "[ INFO ] Role ID for ${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION}: ${ROLE_ID} (base64: $(echo -n "${ROLE_ID}" | base64))"

   # Get secretid
   SECRET_ID=$(vault write -f auth/approle/role/${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION}/secret-id | xargs | awk '{ print $6 }')

   echo -e "[ INFO ] Secret ID for ${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION}: ${SECRET_ID} (base64: $(echo -n "${SECRET_ID}" | base64))"
   echo "[ INFO ] Create a Kubernetes secret"
   echo -e "---
apiVersion: v1
kind: Secret
metadata:
   name: ${KUBERNETES_APPLICATION}-approle
   namespace: ${KUBERNETES_NAMESPACE}
   labels:
       app: ${KUBERNETES_APPLICATION}
       role: approle
type: Opaque
data:
   role_id: $(echo -n "${ROLE_ID}" | base64)
   secret_id: $(echo -n "${SECRET_ID}" | base64)" > /tmp/${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION}.yaml

   kubectl -n ${KUBERNETES_NAMESPACE} apply -f /tmp/${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION}.yaml >/dev/null

   if [[ "$(kubectl -n ${KUBERNETES_NAMESPACE} get secrets | grep ${KUBERNETES_APPLICATION}-approle | awk '{ print $1 }')" == "${KUBERNETES_APPLICATION}-approle" ]]; then
       echo -e "[ INFO ] Secret created: ${KUBERNETES_APPLICATION}-approle in ${KUBERNETES_NAMESPACE} namespace"
       rm -f /tmp/${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION}.yaml
   else
       echo -e "[ WARNING ] Secret has not been created. One can create is manually: kubectl -n ${KUBERNETES_NAMESPACE} apply -f /tmp/${KUBERNETES_NAMESPACE}-${KUBERNETES_APPLICATION}.yaml"
   fi
fi

vault write apps/${KUBERNETES_NAMESPACE}/${KUBERNETES_APPLICATION}/example FOO="bar"
