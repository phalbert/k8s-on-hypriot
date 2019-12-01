kubectl -n infra create secret generic minio --from-literal="accesskey=$S3_ACCESS_KEY" \
                                             --from-literal="secretkey=$S3_SECRET_KEY"