FROM node:0.12-slim

MAINTAINER Luciano Colosio "luciano.colosio@namshi.com"

ENV NGINX_VERSION 1.9.4
ENV NPS_VERSION 1.9.32.6

RUN apt-get update && apt-get install -y \
      python \
      python-pip \
      python-dev \
      nginx-extras \
      libfreetype6 \
      libfontconfig1 \
      wget build-essential \
      zlib1g-dev \
      libpcre3 \
      libpcre3-dev \
      unzip -y && \
    cd /usr/src && \
      wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip && \
      unzip release-${NPS_VERSION}-beta.zip && \
      cd /usr/src/ngx_pagespeed-release-${NPS_VERSION}-beta/ && \
        wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && \
        tar -xzvf ${NPS_VERSION}.tar.gz && \
      cd /usr/src && \
        wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
        tar -xvzf nginx-${NGINX_VERSION}.tar.gz && \
        cd /usr/src/nginx-${NGINX_VERSION}/ && \
          ./configure --add-module=/usr/src/ngx_pagespeed-release-${NPS_VERSION}-beta \
            --prefix=/usr/local/share/nginx --conf-path=/etc/nginx/nginx.conf \
            --sbin-path=/usr/local/sbin --error-log-path=/var/log/nginx/error.log && \
            make && make install && \
      cd /usr && \
      rm -fr /usr/src/* && \
      mkdir -p /var/pagespeed/cache && \
      apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
        find /var/log -type f | while read f; do echo -ne '' > $f; done;

COPY ./config/default /etc/nginx/sites-enabled/default
