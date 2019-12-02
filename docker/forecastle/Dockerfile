FROM alpine:3.10 as clone

RUN apk add --no-cache git

WORKDIR /usr/src/app

RUN git clone https://github.com/stakater/Forecastle.git .
RUN git checkout v1.0.36

FROM node:12.11.1 as build-ui

WORKDIR /usr/src/app/frontend

COPY --from=clone /usr/src/app/frontend .
RUN yarn install && yarn build

FROM golang:1.13.1-alpine as build

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=arm

RUN apk update

RUN apk -v --update \
    add git build-base && \
    rm -rf /var/cache/apk/* && \
    mkdir -p "$GOPATH/src/github.com/stakater/Forecastle/frontend/"

WORKDIR $GOPATH/src/github.com/stakater/Forecastle

ARG PACKR_VERSION=2.7.1
ARG PACKR_FILENAME=packr_${PACKR_VERSION}_linux_386.tar.gz
ARG PACKR_URL=https://github.com/gobuffalo/packr/releases/download/v${PACKR_VERSION}/${PACKR_FILENAME}

RUN mkdir -p /tmp/packr/ && \
    wget ${PACKR_URL} -O /tmp/packr/${PACKR_FILENAME} && \
    tar -xzvf /tmp/packr/${PACKR_FILENAME} -C /tmp/packr/ && \
    mv /tmp/packr/packr2 /usr/local/bin/packr2 && \
    rm -rf /tmp/packr

COPY --from=clone /usr/src/app/pkg ./pkg
COPY --from=clone /usr/src/app/forecastle.go .
COPY --from=clone /usr/src/app/go.sum .
COPY --from=clone /usr/src/app/go.mod .

COPY --from=build-ui /usr/src/app/frontend/build ./frontend/build

RUN go mod download && \
    packr2 build -a --installsuffix cgo --ldflags="-s" -o /Forecastle && \
    packr2 clean && \
    chmod +x /Forecastle

## Run

FROM arm32v6/alpine:3.9

RUN apk add --update ca-certificates

COPY --from=build /Forecastle /bin/Forecastle

ENTRYPOINT ["/bin/Forecastle"]