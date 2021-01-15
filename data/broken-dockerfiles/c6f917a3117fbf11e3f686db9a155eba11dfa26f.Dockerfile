FROM perl:latest

ENV NGINX_VERSION 1.14.0

RUN cpanm Test::Harness
RUN cpanm Test::Nginx

COPY config /root/nginx-length-hiding-filter-module/
COPY ngx_http_length_hiding_filter_module.c /root/nginx-length-hiding-filter-module/

RUN curl -fSL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz \
    && tar zxfv nginx.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure --add-module=/root/nginx-length-hiding-filter-module \
    && make \
    && make install \
    && ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/nginx/logs/error.log

COPY t/*.t /root/nginx-length-hiding-filter-module/t/

WORKDIR /root/nginx-length-hiding-filter-module

ENV TEST_NGINX_BINARY /usr/local/nginx/sbin/nginx
CMD prove -v --timer t/*.t