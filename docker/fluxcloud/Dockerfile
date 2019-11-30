#
# Compile
#

FROM golang:1.12-alpine as build

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=arm

WORKDIR /go/src/github.com/justinbarrick/fluxcloud

RUN apk add --no-cache openssh-client 'git>=2.12.0' 'gnutls>=3.6.7' gnupg gawk socat build-base gcc wget bash curl \
    && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing git-secret

RUN git clone https://github.com/justinbarrick/fluxcloud.git .
RUN git checkout v0.3.9

RUN go build -o fluxcloud ./cmd

FROM alpine:3.10.0@sha256:ca1c944a4f8486a153024d9965aafbe24f5723c1d5c02f4964c045a16d19dc54 as certs
RUN apk update && apk add ca-certificates

#FROM gcr.io/distroless/static@sha256:48e0d165f07d499c02732d924e84efbc73df8021b12c24940e18a9306589430e

FROM arm32v6/alpine:3.10

WORKDIR /

COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /go/src/github.com/justinbarrick/fluxcloud/fluxcloud /fluxcloud
EXPOSE 3031

ENTRYPOINT ["/fluxcloud"]