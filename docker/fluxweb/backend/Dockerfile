#
# Compile
#

FROM node:10-alpine as clone

RUN apk add --no-cache openssh-client 'git>=2.12.0' 'gnutls>=3.6.7' gnupg gawk socat build-base gcc wget bash curl \
    && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing git-secret

WORKDIR /fluxweb

RUN git clone https://github.com/flux-web/flux-web.git . && \
    git checkout master

FROM library/golang as builder

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=arm \
    APP_DIR=$GOPATH/src/flux-web

RUN go get github.com/tools/godep       \
    && go get github.com/astaxie/beego  \
    && go get github.com/ericchiang/k8s \
    && go get github.com/ghodss/yaml    \
    && go get github.com/gorilla/websocket

RUN go install -a std

WORKDIR $GOPATH/src/flux-web

COPY --from=clone /fluxweb/backend .

RUN $GOPATH/bin/linux_arm/godep get -v

RUN go build -ldflags '-w -s' -o /flux-web && \
    cp -r views/ /views && \
    cp -r conf/ /conf

#
# Deploy
#

FROM arm32v6/alpine:3.10.0

RUN adduser -D -u 1000 flux-web

COPY --from=builder /flux-web /flux-web
COPY --from=builder /views /views
COPY --from=builder /conf /conf

USER 1000

ENTRYPOINT ["/flux-web"]