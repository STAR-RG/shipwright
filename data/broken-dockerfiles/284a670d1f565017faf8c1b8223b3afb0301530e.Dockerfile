# Docker images for nginx module development
FROM buildpack-deps:jessie-curl
RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
            automake \
            gcc \
            libc6-dev \
            libjansson-dev \
            libpcre3-dev \
            libssl-dev \
            libtool \
            libz-dev \
            make \
            pkg-config \
            valgrind \
    && rm -rf /var/lib/apt/lists/*

# Add nginx source
RUN mkdir -p /usr/src/nginx && \
    curl -SL https://nginx.org/download/nginx-1.13.0.tar.gz \
    | tar -xzC /usr/src/nginx

# Install libjwt
COPY libjwt /usr/src/libjwt
WORKDIR /usr/src/libjwt
RUN autoreconf -i && \
    ./configure --prefix="/usr/" && \
    make && \
    make install

# Add module config
COPY config /usr/src/nginx/nginx-jwt/

# Configure nginx (same options as official nginx debian build)
WORKDIR /usr/src/nginx/nginx-1.13.0
RUN ./configure \
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
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --add-module=../nginx-jwt

# Build nginx (will fail)
RUN make || true

# Add module source (here, for faster recompilation)
COPY ngx_http_jwt_module.c /usr/src/nginx/nginx-jwt/

# Build nginx (now really)
RUN make && make install

RUN useradd nginx
RUN mkdir -p /var/log/nginx /var/cache/nginx

# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
