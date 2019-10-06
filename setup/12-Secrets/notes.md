kubectl -n vault port-forward vault-0 8200:8200

set -xg VAULT_ADDR http://127.0.0.1:8200
set -xg VAULT_TOKEN s.S6pC3b6kgbofZ09XbouITC8r
set -xg VAULT_TOKEN (curl --slient  --data '{ "role_id": "68cee7b8-b8bb-ec1e-20b9-88d87a510833", "secret_id": "d33377fe-41b6-f54e-1063-b440301256b8" }' --request POST "${VAULT_ADDR}/v1/auth/approle/login")

vault audit enable file file_path=stdout
vault secrets enable -path=apps kv
vault auth enable approle
vault auth enable userpass

vault write auth/userpass/users/stephen password="???" policies="admin"

vault token create -policy=metrics -display-name=prometheus -no-default-policy
curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET "$VAULT_ADDR/v1/sys/metrics?format=prometheus"



vault write auth/approle/role/kuard secret_id_ttl="" token_num_uses=0 token_ttl="" token_max_ttl="" secret_id_num_uses=0 policies="kuard"
vault read auth/approle/role/kuard/role-id
vault write -force auth/approle/role/kuard/secret-id

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "foo": "world" } }' $VAULT_ADDR/v1/apps/data/hello
curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET $VAULT_ADDR/v1/apps/data/hello
    

admin.hcl
path "*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}

metrics.hcl
path "sys/metrics*" {
  capabilities = ["read", "list"]
}
