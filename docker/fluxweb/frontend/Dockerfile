#
# Compile
#

FROM node:10-alpine as builder

RUN apk add --no-cache openssh-client 'git>=2.12.0' 'gnutls>=3.6.7' gnupg gawk socat build-base gcc wget bash curl \
    && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing git-secret

WORKDIR /fluxweb

RUN git clone https://github.com/flux-web/flux-web.git . && \
    git checkout master

WORKDIR /build

RUN cp -R /fluxweb/frontend/* .

RUN npm install && npm run build

#
# Deploy
#

FROM arm32v6/node:10-alpine

ENV APP_PORT=8080

WORKDIR /build

COPY --from=builder /build /build

EXPOSE 8080

CMD ["npm", "start"]