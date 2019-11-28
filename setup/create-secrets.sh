#!/bin/bash

source ".env"

kubectl -n infra create secret generic linode-dynamic-dns --from-literal="token=$LINODE_TOKEN"