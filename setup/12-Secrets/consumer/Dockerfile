FROM arm32v6/alpine:3.9

ARG CONFD_VERSION=0.16.0

COPY ./entrypoint.sh /entrypoint.sh

ADD https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-arm64 /usr/bin/confd

RUN apk add --update --no-cache \
        openssl \
        curl \
        ca-certificates \
        bind-tools \
        net-tools \
        jq \
        bash && \
    mkdir /etc/confd && \
    chmod +x /usr/bin/confd /entrypoint.sh

USER root

ENTRYPOINT ["/entrypoint.sh"]

CMD ["confd"]
