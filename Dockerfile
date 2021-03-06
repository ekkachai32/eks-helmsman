FROM praqma/helmsman:latest as helm
FROM gcr.io/heptio-images/authenticator:v0.3.0-scratch as authenticator
FROM python:3.7-alpine

COPY --from=helm /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=helm /usr/local/bin/helm /usr/local/bin/helm
COPY --from=helm /bin/helmsman /usr/local/bin/helmsman
COPY --from=authenticator /heptio-authenticator-aws /usr/local/bin/aws-iam-authenticator

ARG DOCKER_CLI_VERSION="17.06.2-ce"
ENV DOWNLOAD_URL="https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_CLI_VERSION.tgz"

ENV HELM_HOME=/helm/.helm
ENV HELM_DIFF_VERSION=v2.11.0+3

RUN pip install --no-cache awscli && \
    apk --update --no-cache add bash openssh curl git jq && \
    adduser -h /helm -D helm && \
    mkdir /tmp/download && \
    curl -L $DOWNLOAD_URL | tar -xz -C /tmp/download && \
    mv /tmp/download/docker/docker /usr/local/bin/ && \
    rm -rf /tmp/download && \
    apk del curl && \
    rm -rf /var/cache/apk/* 

USER helm

RUN helm init --client-only && \
    wget -O- https://github.com/databus23/helm-diff/releases/download/${HELM_DIFF_VERSION}/helm-diff-linux.tgz | tar -xvzC ${HELM_HOME}/plugins

ENTRYPOINT /bin/bash
