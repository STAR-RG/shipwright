FROM alpine:3.8

LABEL Description="reverse with nginx based on alpine" \
      tags="latest 1.15.7 1.15" \
      maintainer="xataz <https://github.com/xataz>" \
      build_ver="201812072230"

ARG NGINX_VER=1.15.7
ARG NGINX_GPG="573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
               A09CD539B8BB8CBE96E82BDFABD4D3B3F5806B4D \
               4C2C85E705DC730833990C38A9376139A524C53E \
               65506C02EFC250F1B7A3D694ECF0E90B2C172083 \
               B0F4253373F8F6F510D42178520A9993A1C052F8 \
               7338973069ED3F443F4D37DFA64FD5B17ADB39A8"
ARG BUILD_CORES
ARG NGINX_CONF="--prefix=/nginx \
                --sbin-path=/usr/local/sbin/nginx \
                --http-log-path=/nginx/log/nginx_access.log \
                --error-log-path=/nginx/log/nginx_error.log \
                --pid-path=/nginx/run/nginx.pid \
                --lock-path=/nginx/run/nginx.lock \
                --user=reverse --group=reverse \
                --with-http_ssl_module \
                --with-http_v2_module \
                --with-http_gzip_static_module \
                --with-http_stub_status_module \
                --with-threads \
                --with-pcre-jit \
                --with-ipv6 \
                --with-file-aio \
                --without-http_ssi_module \
                --without-http_scgi_module \
                --without-http_uwsgi_module \
                --without-http_geo_module \
                --without-http_autoindex_module \
                --without-http_split_clients_module \
                --without-http_memcached_module \
                --without-http_empty_gif_module \
                --without-http_browser_module"
ARG NGINX_3RD_PARTY_MODULES="--add-module=/tmp/headers-more-nginx-module \
                            --add-module=/tmp/nginx-ct \
                            --add-module=/tmp/ngx_brotli"
ARG OPENSSL_VER=1.1.1a
ARG LEGO_VER=v1.2.1

RUN export BUILD_DEPS="build-base \
                    pcre-dev \
                    zlib-dev \
                    libc-dev \
                    wget \
                    gnupg \
                    go \
                    git \
                    autoconf \
                    automake \
                    libtool \
                    cmake \
                    binutils \
                    linux-headers \
                    jemalloc-dev" \
    && NB_CORES=${BUILD_CORES-$(grep -c "processor" /proc/cpuinfo)} \
    && apk upgrade --no-cache \
    && apk add --no-cache ${BUILD_DEPS} \
                s6 \
                su-exec \
                ca-certificates \
                curl \
                jq \
                pcre \
                zlib \
                bash \
                libgcc \
                libstdc++ \
                jemalloc \
                bind-tools \
                libressl \
    && cd /tmp \
    # Download source
    && git clone https://github.com/openresty/headers-more-nginx-module --depth=1 /tmp/headers-more-nginx-module \
    && git clone https://github.com/bagder/libbrotli --depth=1 /tmp/libbrotli \
    && git clone https://github.com/google/ngx_brotli --depth=1 /tmp/ngx_brotli \
    && wget -q http://nginx.org/download/nginx-${NGINX_VER}.tar.gz -O /tmp/nginx-${NGINX_VER}.tar.gz \
    && wget -q http://nginx.org/download/nginx-${NGINX_VER}.tar.gz.asc -O /tmp/nginx-${NGINX_VER}.tar.gz.asc \
    && wget -q https://www.openssl.org/source/openssl-${OPENSSL_VER}.tar.gz -O /tmp/openssl-${OPENSSL_VER}.tar.gz \
    && git clone https://github.com/grahamedgecombe/nginx-ct --depth=1 /tmp/nginx-ct \
    # Brotli
    && cd /tmp/libbrotli \
    && ./autogen.sh \
    && ./configure \
    && mkdir brotli/c/tools/.deps \
    && touch brotli/c/tools/.deps/brotli-brotli.Po \
    && make -j ${NB_CORES} \
    && make install \
    && cd /tmp/ngx_brotli \
    && git submodule update --init \ 
    # OpenSSL
    && cd /tmp \
    && tar xzf openssl-${OPENSSL_VER}.tar.gz \
    # Nginx
    && cd /tmp \
    && for server in ha.pool.sks-keyservers.net hkp://keyserver.ubuntu.com:80 hkp://p80.pool.sks-keyservers.net:80 pgp.mit.edu; \
	    do \
            echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
            gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys $NGINX_GPG && found=yes && break; \
        done \
    && gpg --batch --verify nginx-${NGINX_VER}.tar.gz.asc nginx-${NGINX_VER}.tar.gz \
    && tar xzf nginx-${NGINX_VER}.tar.gz \
    && cd /tmp/nginx-${NGINX_VER} \
    && ./configure ${NGINX_CONF} ${NGINX_3RD_PARTY_MODULES} \
                        --with-cc-opt="-O3 -fPIE -fstack-protector-strong -D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security -Wno-deprecated-declarations" \
                        --with-ld-opt="-lrt -ljemalloc -Wl,-Bsymbolic-functions -Wl,-z,relro" \
                        --with-openssl-opt='no-async enable-ec_nistp_64_gcc_128 no-shared no-ssl2 no-ssl3 no-comp no-idea no-weak-ssl-ciphers -DOPENSSL_NO_HEARTBEATS -O3 -fPIE -fstack-protector-strong -D_FORTIFY_SOURCE=2' \
                        --with-openssl=/tmp/openssl-${OPENSSL_VER} \
    && make -j ${NB_CORES} \
    && make install \
    # Lego
    && mkdir -p /tmp/go/bin \
    && export GOPATH=/tmp/go \
    && export GOBIN=$GOPATH/bin \
    && git config --global http.https://gopkg.in.followRedirects true \
    && git clone -b ${LEGO_VER} https://github.com/xenolf/lego /tmp/go/src/github.com/xenolf/lego \
    && if [ "${LEGO_VER}" == "v0.5.0" ]; then sed -i '70s/record/egoscale.UpdateDNSRecord(record)/' /tmp/go/src/github.com/xenolf/lego/providers/dns/exoscale/exoscale.go; fi \
    && go get -v github.com/xenolf/lego \
    && mv /tmp/go/bin/lego /usr/local/bin/lego \
    # ct-submit
    && go get github.com/grahamedgecombe/ct-submit \
    && mv /tmp/go/bin/ct-submit /usr/local/bin/ct-submit \
    # gucci
    && go get github.com/noqcks/gucci \
    && mv /tmp/go/bin/gucci /usr/local/bin/gucci \
    # Cleanup
    && apk del --no-cache ${BUILD_DEPS} \
    && rm -rf /tmp/* /root/.cache

COPY rootfs /
RUN chmod +x /usr/local/bin/startup /etc/s6.d/*/*

EXPOSE 8080 8443

ENV UID=991 \
    GID=991 \
    EMAIL=admin@mydomain.local \
    SWARM=disable \
    TLS_VERSIONS="TLSv1.1 TLSv1.2" \
    CIPHER_SUITE="EECDH+CHACHA20:EECDH+AESGCM" \
    ECDH_CURVE="X25519:P-521:P-384:P-256"

ENTRYPOINT ["/usr/local/bin/startup"]
CMD ["/bin/s6-svscan", "/etc/s6.d"]
