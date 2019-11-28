FROM arm32v6/golang:1.13.1-alpine3.10 AS build

RUN apk add --no-cache make git

RUN mkdir -p /go/src/github.com/kelseyhightower/ && \
  ln -s /go/src/github.com/kelseyhightower/confd /app

RUN git clone https://github.com/kelseyhightower/confd.git /go/src/github.com/kelseyhightower/confd && \
    cd /go/src/github.com/kelseyhightower/confd && \
    make

# ====================

FROM arm32v6/alpine:3.9

COPY entrypoint.sh /entrypoint.sh

COPY --from=build /app/bin/confd /usr/bin/confd

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
