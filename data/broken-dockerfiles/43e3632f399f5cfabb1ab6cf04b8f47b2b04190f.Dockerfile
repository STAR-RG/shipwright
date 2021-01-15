FROM ruby:2.4-alpine
LABEL maintainer=helder

RUN set -e; \
    apk add --no-cache \
        tini \
        libstdc++ \
        sqlite-libs \
    ; \
    apk add --no-cache --virtual .build-deps \
        build-base \
        g++ \
        make \
        musl-dev \
        openssl-dev \
        sqlite-dev \
    ; \
    gem install mailcatcher --no-rdoc --no-ri; \
    apk del .build-deps; \
    rm -rf  $GEM_HOME/cache/*

# smtp (25) and ip (80) ports
EXPOSE 25 80

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["mailcatcher", "--smtp-ip=0.0.0.0", "--smtp-port=25", "--http-ip=0.0.0.0", "--http-port=80", "-f"]
