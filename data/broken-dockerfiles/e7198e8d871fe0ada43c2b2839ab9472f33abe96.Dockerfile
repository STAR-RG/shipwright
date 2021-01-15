FROM alpine:3.10.1 AS nginx-naxsi-build

RUN set -ex ; \
    addgroup -S nginx ; \
    adduser \
        -D \
        -S \
        -h /var/cache/nginx \
        -s /sbin/nologin \
        -G nginx \
        nginx ;

ENV NAXSI_VERSION=@NAXSI_VERSION@ \
    NAXSI_TAG=@NAXSI_TAG@ \
    NGINX_VERSION=@NGINX_VERSION@

WORKDIR /tmp

RUN set -ex ; \
    gpg_keys="\
        0xB0F4253373F8F6F510D42178520A9993A1C052F8\
        251A28DE2685AED4\
        " ; \
    apk add --no-cache --virtual .build-deps \
        curl \
        gnupg \
    ; \
    curl \
        -fSL \
        http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
        -o nginx.tar.gz \
    ; \
    curl \
        -fSL \
        http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc \
        -o nginx.tar.gz.asc \
    ; \
    curl \
        -fSL \
        https://github.com/nbs-system/naxsi/archive/$NAXSI_VERSION.tar.gz \
        -o naxsi.tar.gz \
    ; \
    curl \
        -fSL \
        https://github.com/nbs-system/naxsi/releases/download/$NAXSI_TAG/naxsi-$NAXSI_VERSION.tar.gz.sig \
        -o naxsi.tar.gz.sig \
    ; \
    \
    export GNUPGHOME="$(mktemp -d)" ; \
    gpg \
        --keyserver "ha.pool.sks-keyservers.net" \
        --keyserver-options timeout=10 \
        --recv-keys $gpg_keys \
    ; \
    gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz ; \
    gpg --batch --verify naxsi.tar.gz.sig naxsi.tar.gz ; \
    rm -rf \
        "$GNUPGHOME" \
        naxsi.tar.gz.sig \
        nginx.tar.gz.asc \
    ; \
    apk del .build-deps ;



RUN set -ex ; \
    config=" \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --add-module=/tmp/naxsi-$NAXSI_VERSION/naxsi_src/ \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-http_xslt_module=dynamic \
        --with-http_image_filter_module=dynamic \
        --with-http_geoip_module=dynamic \
        --with-threads \
        --with-stream \
        --with-stream_ssl_module \
        --with-stream_ssl_preread_module \
        --with-stream_realip_module \
        --with-stream_geoip_module=dynamic \
        --with-http_slice_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-compat \
        --with-file-aio \
        --with-http_v2_module \
        " \
    ; \
    \
    apk add --no-cache --virtual .build-deps \
        clang \
        gcc \
        gd-dev \
        geoip-dev \
        gettext \
        libc-dev \
        libxslt-dev \
        linux-headers \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
    ; \
    \
    tar -xzf naxsi.tar.gz ; \
    tar -xzf nginx.tar.gz ; \
    \
    rm \
        naxsi.tar.gz \
        nginx.tar.gz \
    ; \
    \
    cd nginx-$NGINX_VERSION ; \
    CC=clang CFLAGS="-pipe -O" ./configure $config ; \
    make -j$(getconf _NPROCESSORS_ONLN) ; \
    make install ; \
    rm -rf /etc/nginx/html/ ; \
    mkdir /etc/nginx/conf.d/ ; \
    mkdir -p /usr/share/nginx/html/ ; \
    install -m644 \
        ../naxsi-$NAXSI_VERSION/naxsi_config/naxsi_core.rules \
        /etc/nginx \
    ; \
    install -m644 html/index.html /usr/share/nginx/html/ ; \
    install -m644 html/50x.html /usr/share/nginx/html/ ; \
    ln -s ../../usr/lib/nginx/modules /etc/nginx/modules ; \
    strip /usr/sbin/nginx* ; \
    strip /usr/lib/nginx/modules/*.so ; \
    \
    rm -rf \
        /tmp/naxsi-$NAXSI_VERSION \
        /tmp/nginx-$NGINX_VERSION \
    ; \
    \
    mv /usr/bin/envsubst /tmp/ ; \
    \
    run_deps="$( \
        scanelf \
                --needed \
                --nobanner \
                /usr/sbin/nginx \
                /usr/lib/nginx/modules/*.so \
                /tmp/envsubst \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u \
            | xargs -r apk info --installed \
            | sort -u \
        )" \
    ; \
    apk add --no-cache --virtual .nginx-run-deps $run_deps ; \
    apk del .build-deps ; \
    mv /tmp/envsubst /usr/local/bin/ ; \
    \
    ln -sf /dev/stdout /var/log/nginx/access.log ; \
    ln -sf /dev/stderr /var/log/nginx/error.log ;

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx.vh.default.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh


FROM scratch
LABEL maintainer "Dimitri G. <dev@dmgnx.net>"

COPY --from=nginx-naxsi-build / /

VOLUME "/etc/nginx/conf.d" \
       "/etc/nginx/naxsi" \
       "/etc/nginx/ssl" \
       "/usr/share/nginx/html" \
       "/var/log/nginx"

EXPOSE 80/tcp 443/tcp

STOPSIGNAL SIGQUIT

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "-g", "daemon off;" ]
