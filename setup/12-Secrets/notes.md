
kubectl -n vault port-forward vault-0 8200:8200
export VAULT_ADDR=http://127.0.0.1:8200

set -xg VAULT_ADDR http://127.0.0.1:8200
set -xg VAULT_TOKEN s.bgQ6lJnj5yYDcfgf6ZsGXx8P

vault write auth/approle/role/kuard \
    secret_id_ttl=120m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=0 \
    policies="kuard"

     vault read auth/approle/role/kuard/role-id

vault audit enable file file_path=stdout

     vault write -force auth/approle/role/kuard/secret-id

curl \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{ "data": { "foo": "world" } }' \
    $VAULT_ADDR/v1/apps/data/hello

curl \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -X GET \
    $VAULT_ADDR/v1/apps/data/hello
    
    
    
    set -xg JSON (jq -c -n --arg role_id 'd28e32a5-ce31-0013-b585-5fce406e2ca1' --arg secret_id '572f449f-4d52-11be-4436-5b2dc1a0dfc8' "{ role_id: \$role_id, secret_id: \$secret_id }")

curl \
          --silent \
          --data $JSON \
  --request POST "http://localhost:8200/v1/auth/approle/login"
