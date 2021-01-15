# Dockerfile for Kong testing, and development.
#
# This image is based on:
#
#   Dockerfile - alpine-fat
#   https://github.com/openresty/docker-openresty
#
#   This is an alpine-based build that keeps some build-related
#   packages, has perl installed for opm, and includes luarocks.

FROM alpine:latest

# Evan maintains openresty/openresty
# Ian maintains mrsaints/docker-kong-dev
LABEL maintainer "Evan Wies <evan@neomantra.net>, Ian L. <os@fyianlai.com>"

# Docker Build Arguments

ARG SERF_VERSION="0.7.0"

# `--without-luajit-lua52` compilation flag is required
# for Kong to work with OpenResty 1.11.2.4
ARG RESTY_VERSION="1.11.2.4"

ARG RESTY_LUAROCKS_VERSION="2.4.2"
ARG RESTY_OPENSSL_VERSION="1.0.2j"
ARG RESTY_PCRE_VERSION="8.39"
ARG RESTY_J="1"
ARG RESTY_CONFIG_OPTIONS="\
    --with-file-aio \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module=dynamic \
    --with-ipv6 \
    --with-mail \
    --with-mail_ssl_module \
    --with-md5-asm \
    --with-pcre-jit \
    --with-sha1-asm \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
    --without-luajit-lua52 \
    "

# These are not intended to be user-specified
ARG _RESTY_CONFIG_DEPS="--with-openssl=/tmp/openssl-${RESTY_OPENSSL_VERSION} --with-pcre=/tmp/pcre-${RESTY_PCRE_VERSION}"


# 1) Install apk dependencies
# 2) Download and untar OpenSSL, PCRE, and OpenResty
# 3) Build OpenResty
# 4) Cleanup

RUN \
    apk add --no-cache --virtual .build-deps \
        curl \
        gd-dev \
        geoip-dev \
        libxslt-dev \
        perl-dev \
        readline-dev \
        zlib-dev \
    && apk add --no-cache \
        bash \
        build-base \
        curl \
        gd \
        geoip \
        git \
        libgcc \
        libxslt \
        linux-headers \
        make \
        nano \
        openssl \
        openssl-dev \
        perl \
        unzip \
        zlib \
    && cd /tmp \
    && curl -fSL https://www.openssl.org/source/openssl-${RESTY_OPENSSL_VERSION}.tar.gz -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && curl -fSL https://ftp.pcre.org/pub/pcre/pcre-${RESTY_PCRE_VERSION}.tar.gz -o pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && curl -fSL https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz \
    && tar xzf openresty-${RESTY_VERSION}.tar.gz \
    && cd /tmp/openresty-${RESTY_VERSION} \
    && ./configure -j${RESTY_J} ${_RESTY_CONFIG_DEPS} ${RESTY_CONFIG_OPTIONS} \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && cd /tmp \
    && rm -rf \
        openssl-${RESTY_OPENSSL_VERSION} \
        openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
        openresty-${RESTY_VERSION}.tar.gz openresty-${RESTY_VERSION} \
        pcre-${RESTY_PCRE_VERSION}.tar.gz pcre-${RESTY_PCRE_VERSION} \
    && curl -fSL http://luarocks.org/releases/luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz -o luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && tar xzf luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && cd luarocks-${RESTY_LUAROCKS_VERSION} \
    && ./configure \
        --prefix=/usr/local/openresty/luajit \
        --with-lua=/usr/local/openresty/luajit \
        --lua-suffix=jit \
        --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1 \
    && make build \
    && make install \
    && cd /tmp \
    && rm -rf luarocks-${RESTY_LUAROCKS_VERSION} luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

# Add additional binaries into PATH for convenience
# Also, include path to Kong 'binary'
ENV PATH=$PATH:/usr/local/openresty/luajit/bin/:/usr/local/openresty/nginx/sbin/:/usr/local/openresty/bin/:/kong/bin/

# Install Serf
RUN cd /tmp/ \
    && wget https://releases.hashicorp.com/serf/${SERF_VERSION}/serf_${SERF_VERSION}_linux_amd64.zip \
    && unzip serf_${SERF_VERSION}_linux_amd64.zip \
    && mv serf /usr/local/bin/serf \
    && rm -rf serf_${SERF_VERSION}_linux_amd64.zip

# Fix path to OpenSSL directory for luarocks to work
ENV OPENSSL_DIR=/usr/

# Disable code caching so local changes can be tested without restarting Kong
ENV KONG_LUA_CODE_CACHE=false

# Enable detailed logging
ENV KONG_LOG_LEVEL=debug

# Set Kong version
ENV KONG_VERSION=c7b4b48e6fd26c2789e38458d0a099ef08e631bb

# Install Kong from source
RUN mkdir /kong/ \
    && cd /kong/ \
    && git clone https://github.com/Mashape/kong.git . \
    && git checkout $KONG_VERSION \
    && make install \
    && make dev \
    && apk del .build-deps

WORKDIR /kong/

RUN nginx -V && resty -V && luarocks --version && serf version

# Ports for proxy, admin API, and clustering
EXPOSE 7946 8000 8001 8443
