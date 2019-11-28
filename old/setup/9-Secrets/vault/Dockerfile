FROM arm32v6/vault:1.2.3

RUN mkdir -p /opt/vault && \
    apk add --no-cache nmap-ncat jq bash

COPY unseal.sh /opt/vault/unseal.sh

RUN chmod +x /opt/vault/unseal.sh

CMD ["/bin/bash", "/opt/vault/unseal.sh"]
