FROM debian:wheezy

MAINTAINER John E Vincent <lusis.org+github.com@gmail.com>

ENV 	DEBIAN_FRONTEND noninteractive
ENV 	LANGUAGE en_US.UTF-8
ENV 	LANG en_US.UTF-8
ENV 	LC_ALL en_US.UTF-8



RUN apt-get update && apt-get install -y \
    supervisor \
    git \
    curl \
    build-essential \
    ruby1.9.1-full \
    libssl-dev \
    libreadline-dev \
    libxslt1-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libexpat1-dev \
    libicu-dev \
    unzip \
    libpcre3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -L  https://github.com/coreos/etcd/releases/download/v0.4.6/etcd-v0.4.6-linux-amd64.tar.gz -o etcd-v0.4.6-linux-amd64.tar.gz && \
    tar -zxvf etcd-v0.4.6-linux-amd64.tar.gz && \
    cp etcd-v0.4.6-linux-amd64/etcd /

RUN mkdir /build && \
    curl -LO http://openresty.org/download/ngx_openresty-1.7.7.1.tar.gz && \
    cd /build/ && \
    tar ozxf /ngx_openresty-1.7.7.1.tar.gz

# Get some additional patches mostly proxy related (in its own group to optimize)
RUN cd /build && \
    git clone https://github.com/yaoweibin/nginx_upstream_check_module && \
    git clone https://github.com/gnosek/nginx-upstream-fair && \
    git clone https://github.com/lusis/nginx-sticky-module && \
    git clone https://github.com/yaoweibin/nginx_tcp_proxy_module

# Patch and build    
RUN cd /build/ngx_openresty-1.7.7.1/bundle/nginx-1.7.7 && \
    patch -p1 < /build/nginx_upstream_check_module/check_1.7.5+.patch && \
    patch -p1 < /build/nginx_tcp_proxy_module/tcp.patch

RUN mkdir /tmp/client_body_tmp && mkdir /tmp/proxy_temp && cd /build/ngx_openresty-1.7.7.1 && \
    ./configure --prefix=/opt/openresty \
    --with-luajit \
    --with-luajit-xcflags=-DLUAJIT_ENABLE_LUA52COMPAT \
    --http-client-body-temp-path=/tmp/client_body_temp \
    --http-proxy-temp-path=/tmp/proxy_temp \
    --http-log-path=/var/nginx/logs/access.log \
    --error-log-path=/var/nginx/logs/error.log \
    --pid-path=/var/nginx/run/nginx.pid \
    --lock-path=/var/nginx/run/nginx.lock \
    --with-http_stub_status_module \
    --with-http_ssl_module \
    --with-http_secure_link_module \
    --with-http_gzip_static_module \
    --with-http_sub_module \
    --with-http_realip_module \
    --without-http_scgi_module \
    --with-md5-asm \
    --with-sha1-asm \
    --with-file-aio \
    --with-pcre \
    --with-pcre-jit \
    --add-module=/build/nginx_upstream_check_module \
    --add-module=/build/nginx-upstream-fair \
    --add-module=/build/nginx-sticky-module \
    --add-module=/build/nginx_tcp_proxy_module 

RUN cd /build/ngx_openresty-1.7.7.1 && \
    make && \
    make install && \
    cd / && \
    rm -rf /build && \
    ln -sf /opt/openresty/luajit/bin/luajit-2.1.0-alpha /opt/openresty/luajit/bin/lua 

# Hoedown needed for the resty-template markdown rendering
RUN cd /tmp && \
    git clone https://github.com/hoedown/hoedown.git && \
    cd hoedown && \
    make all install && \
    cd / && \
    rm -rf /tmp/hoedown && \
    ldconfig

# Now the luarocks stuff
RUN curl -s http://luarocks.org/releases/luarocks-2.2.0.tar.gz | tar xvz -C /tmp/ \
 && cd /tmp/luarocks-* \
 && ./configure --with-lua=/opt/openresty/luajit \
    --with-lua-include=/opt/openresty/luajit/include/luajit-2.1 \
    --with-lua-lib=/opt/openresty/lualib \
 && make && make install \
 && ln -sf /opt/openresty/luajit/bin/lua /usr/local/bin/lua \
 && rm -rf /tmp/luarocks-*

RUN /usr/local/bin/luarocks install luasec && \
 /usr/local/bin/luarocks install lua-resty-template && \
 /usr/local/bin/luarocks install httpclient && \
 /usr/local/bin/luarocks install lua-resty-http && \
 /usr/local/bin/luarocks install inspect && \
 /usr/local/bin/luarocks install lua-resty-hoedown && \
 /usr/local/bin/luarocks install xml

RUN useradd -r -d /var/nginx nginx && chown -R nginx:nginx /var/nginx/ /tmp/client_body_tmp /tmp/proxy_temp

EXPOSE 3232

ADD ./supervisord.conf /supervisord.conf
CMD /usr/bin/supervisord -c /supervisord.conf
