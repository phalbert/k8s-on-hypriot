FROM golang:1.12-alpine AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=arm

WORKDIR /go/src/github.com/funkypenguin/traefik-forward-auth

RUN apk add --no-cache git

RUN git clone https://github.com/funkypenguin/traefik-forward-auth.git . && \
    git checkout master

# Now we DO need these, for the auto-labeling of the image
ARG BUILD_DATE
ARG VCS_REF

# Good docker practice, plus we get microbadger badges
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/funkypenguin/traefik-forward-auth.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="2.2-r1"

# Add libraries
RUN apk add --no-cache git && \
  go get "github.com/namsral/flag" && \
  go get "github.com/sirupsen/logrus" && \
  apk del git

# Copy & build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm go build -a -installsuffix nocgo -o /traefik-forward-auth .

# Copy into scratch container
FROM arm32v6/alpine:3.10

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /traefik-forward-auth /

ENTRYPOINT ["/traefik-forward-auth"]