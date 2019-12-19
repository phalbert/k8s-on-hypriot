#!/bin/sh

export GOARCH=arm
export GOARM=7
export GO111MODULE=on
export CGO_ENABLED=0
export GOOS=linux

curl -k -sSfL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${GOARCH}/kubectl

curl -k -sSfL -o /tmp/helm-${HELM_VERSION}-linux-${GOARCH}.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-${GOARCH}.tar.gz
tar -xvf /tmp/helm-${HELM_VERSION}-linux-${GOARCH}.tar.gz -C /tmp
mv /tmp/linux-${GOARCH}/helm /usr/local/bin/helm2
chmod +x /usr/local/bin/helm2
rm -rf /tmp/*

curl -k -sSfL -o /tmp/helm-${HELM3_VERSION}-linux-${GOARCH}.tar.gz https://get.helm.sh/helm-${HELM3_VERSION}-linux-${GOARCH}.tar.gz
tar -xvf /tmp/helm-${HELM3_VERSION}-linux-${GOARCH}.tar.gz -C /tmp
mv /tmp/linux-${GOARCH}/helm /usr/local/bin/helm3
chmod +x /usr/local/bin/helm3
rm -rf /tmp/*

git clone --depth 1 -b ${VERSION} https://github.com/fluxcd/helm-operator .
go build -o helm-operator ./cmd/helm-operator
