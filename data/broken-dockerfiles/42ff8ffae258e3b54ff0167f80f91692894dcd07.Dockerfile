FROM alpine:3.7
LABEL Author="Luis Alonzo <wichon@gmail.com>" Description="A Simple apache/php image using alpine Linux for Web Apps"

# Install gnu-libconv required by php5-iconv
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

# Setup apache and php
RUN apk --update add apache2 php5-apache2 curl \
    php5-json php5-phar php5-openssl php5-mysql php5-curl php5-mcrypt php5-pdo_mysql php5-ctype php5-gd php5-xml php5-dom php5-iconv \
    && rm -f /var/cache/apk/* \
    && mkdir /run/apache2 \
    && mkdir -p /opt/utils  

EXPOSE 80

ADD start.sh /opt/utils/

RUN chmod +x /opt/utils/start.sh

ENTRYPOINT ["/opt/utils/start.sh"]