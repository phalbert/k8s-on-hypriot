#
# Compile
#

FROM golang:1.13-alpine as build

ARG KUBECTL_VERSION
ARG HELM_VERSION
ARG HELM3_VERSION
ARG VERSION

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    VERSION=${VERSION} \
    KUBECTL_VERSION=${KUBECTL_VERSION} \
    HELM_VERSION=${HELM_VERSION}

# hadolint ignore=DL3018
RUN apk add --no-cache openssh-client git gnutls gnupg gawk socat curl ca-certificates \
    && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing git-secret

WORKDIR /go/src/github.com/fluxcd/helm-operator
COPY build-helm3.sh /build.sh
RUN chmod +x /build.sh \
    && sh /build.sh

#
# Deploy
#

FROM arm32v6/alpine:3.10
ENV HELM_HOME=/var/fluxd/helm

WORKDIR /home/flux

# hadolint ignore=DL3018
RUN apk add --no-cache openssh-client ca-certificates tini git socat \
    && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing git-secret

COPY ./known_hosts.sh /home/flux/known_hosts.sh
RUN chmod +x /home/flux/known_hosts.sh \
    && sh /home/flux/known_hosts.sh /etc/ssh/ssh_known_hosts \
    && rm /home/flux/known_hosts.sh

COPY ./ssh_config /etc/ssh/ssh_config

RUN mkdir -p /var/fluxd/helm/repository/cache/
COPY ./helm-repositories.yaml /var/fluxd/helm/repository/repositories.yaml

# hadolint ignore=DL3022
COPY --from=build /go/src/github.com/fluxcd/helm-operator/helm-operator /usr/local/bin/helm-operator
RUN chmod +x /usr/local/bin/helm-operator
# hadolint ignore=DL3022
COPY --from=build /usr/local/bin/helm2 /usr/local/bin/helm2
RUN chmod +x /usr/local/bin/helm2
# hadolint ignore=DL3022
COPY --from=build /usr/local/bin/helm3 /usr/local/bin/helm3
RUN chmod +x /usr/local/bin/helm3
# hadolint ignore=DL3022
COPY --from=build /usr/local/bin/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

ENTRYPOINT ["/sbin/tini", "--", "helm-operator"]
