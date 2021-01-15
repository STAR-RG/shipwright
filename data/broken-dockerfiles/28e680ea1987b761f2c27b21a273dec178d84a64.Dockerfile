FROM alpine:latest
MAINTAINER Kirill Bobrov

ARG plugins=hugo

ENV HUGO_VERSION=0.17
ENV CADDY_VERSION=0.9.3

EXPOSE 8888

WORKDIR /srv

RUN apk add --no-cache tar curl

RUN apk add --update wget ca-certificates

RUN curl --silent --show-error --fail --location \
      --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
      "https://caddyserver.com/download/build?os=linux&arch=amd64&features=${plugins}" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy && \
    chmod 0755 /usr/bin/caddy && \
    /usr/bin/caddy -version

RUN wget https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    tar xzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    mv hugo_${HUGO_VERSION}_linux_amd64/hugo_${HUGO_VERSION}_linux_amd64 /usr/bin/hugo && \
    rm -rf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz hugo_${HUGO_VERSION}_linux_amd64

# COPY site/ /srv/
# CMD cd /srv && /usr/bin/caddy
