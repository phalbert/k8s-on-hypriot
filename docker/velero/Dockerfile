FROM arm32v7/alpine:3.10

WORKDIR /tmp

RUN apk add --no-cache ca-certificates \
    && apk add --no-cache --virtual build-dependencies bzip2 curl \
    && curl -k -sSfL -o ./restic_0.9.5_linux_arm.bz2 https://github.com/restic/restic/releases/download/v0.9.5/restic_0.9.5_linux_arm.bz2 \
    && bunzip2 restic_0.9.5_linux_arm.bz2 \
    && mv restic_0.9.5_linux_arm /usr/bin/restic \
    && chmod +x /usr/bin/restic \
    && curl -k -sSfL -o ./velero-v1.2.0-linux-arm.tar.gz https://github.com/vmware-tanzu/velero/releases/download/v1.2.0/velero-v1.2.0-linux-arm.tar.gz \
    && tar -xvf ./velero-v1.2.0-linux-arm.tar.gz \
    && mv velero-v1.2.0-linux-arm/velero /velero \
    && chmod +x /velero \
    && rm -rf /tmp/* \
    && apk del build-dependencies

WORKDIR /

ENTRYPOINT ["/velero"]