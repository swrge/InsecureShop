FROM alpine:3.22

ARG JADX_VERSION=1.5.1
ARG APKTOOL_VERSION=2.11.1

ENV PATH="/opt/jadx/bin:${PATH}"

RUN apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        file \
        openjdk17-jre \
        unzip

RUN set -eux; \
    curl -fsSL "https://github.com/skylot/jadx/releases/download/v${JADX_VERSION}/jadx-${JADX_VERSION}.zip" -o /tmp/jadx.zip; \
    mkdir -p /opt/jadx; \
    unzip -q /tmp/jadx.zip -d /opt/jadx; \
    rm /tmp/jadx.zip

RUN set -eux; \
    mkdir -p /usr/local/lib; \
    curl -fsSL "https://github.com/iBotPeaches/Apktool/releases/download/v${APKTOOL_VERSION}/apktool_${APKTOOL_VERSION}.jar" -o /usr/local/lib/apktool.jar; \
    printf '%s\n' '#!/bin/sh' 'exec java -jar /usr/local/lib/apktool.jar "$@"' > /usr/local/bin/apktool; \
    chmod +x /usr/local/bin/apktool

RUN addgroup -g 1000 auditor \
    && adduser -D -u 1000 -G auditor -s /bin/bash auditor

USER auditor
WORKDIR /home/auditor

CMD ["/bin/bash"]
