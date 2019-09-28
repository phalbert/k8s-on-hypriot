vault write auth/approle/role/kuard \
    secret_id_ttl=120m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=0 \
    policies="kuard"

     vault read auth/approle/role/kuard/role-id


     vault write -force auth/approle/role/kuard/secret-id
