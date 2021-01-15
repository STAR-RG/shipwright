#
# cusspvz/magento.docker
# Magento 2.0 over alpine, nginx, php-fpm and mariadb
#
FROM alpine:latest
MAINTAINER José Moreira <jose.moreira@findhit.com>

ENV DOMAIN=docker.local
ENV REDIRECT_TO_WWW_DOMAIN=0


#
# Install packages
#
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --update \
        curl openssl git \
        supervisor \
        ca-certificates nginx \
        composer@testing php-fpm \
            php-phar \
            php-openssl \
            php-curl \
            php-json \
            php-xml \
            php-zlib \
            php-gd \
            php-ctype \
            php-dom \
            php-mcrypt \
            php-iconv \
            php-intl \
            php-xsl \
            php-zip \
        mysql mysql-client php-pdo_mysql \
    && \
    rm -fR /var/cache/apk/*

#
# MySQL Server
#
ENV MYSQL_HOST=localhost
ENV MYSQL_PORT=3306
ENV MYSQL_DATABASE=magento
ENV MYSQL_USERNAME=root
ENV MYSQL_PASSWORD=ThisShouldBeChangableLater
RUN /usr/bin/mysql_install_db && \
    chown -R mysql:mysql /var/lib/mysql && \
    /usr/bin/mysqld_safe & \
    MYSQL_PID=$!; \
    sleep 20 && /usr/bin/mysqladmin -u root password $MYSQL_PASSWORD && \
    kill $MYSQL_PID
VOLUME /var/lib/mysql
EXPOSE 3306

#
# Magento configs
#
ARG MAGENTO_VERSION=2.0.4
ARG MAGENTO_PUBLIC_KEY=ffc9f467961151f41827c02bc7a9b669
ARG MAGENTO_PRIVATE_KEY=4f64aaa7771b441ef5d72e941c350542
ENV MAGENTO_ROOT=/magento \
    MAGENTO_USER=magento \
    MAGENTO_USER_ID=1000 \
    MAGENTO_GROUP=magento \
    MAGENTO_GROUP_ID=1000
ENV MAGENTO_ADMIN_URI=admin \
    MAGENTO_ADMIN_EMAIL=admin@example.org \
    MAGENTO_ADMIN_FIRSTNAME=John \
    MAGENTO_ADMIN_LASTNAME=Doe \
    MAGENTO_ADMIN_USERNAME=admin \
    MAGENTO_ADMIN_PASSWORD=admin123 \
    MAGENTO_LANGUAGE=en_US \
    MAGENTO_TIMEZONE=Europe/Lisbon \
    MAGENTO_CURRENCY=EUR \
    MAGENTO_ADMIN_USERNAME=admin \
    MAGENTO_ADMIN_USERNAME=admin
RUN mkdir -p ~/.composer && \
    echo "{ \"http-basic\": { \"repo.magento.com\": { \"username\": \"$MAGENTO_PUBLIC_KEY\", \"password\": \"$MAGENTO_PRIVATE_KEY\" } } }" > ~/.composer/auth.json && \
    git clone https://github.com/magento/magento2.git $MAGENTO_ROOT && \
    cd $MAGENTO_ROOT && \
    composer install

VOLUME /magento/app/etc /magento/pub


#
# Nginx Server
#
ENV NGINX_PORT=80
RUN mkdir /tmp/nginx
EXPOSE 80

#
# PHP Configuration
#
ENV PHP_INI=/etc/php/php.ini
RUN \
    sed 's,;always_populate_raw_post_data,always_populate_raw_post_data,g' -i $PHP_INI && \
    sed 's,memory_limit = 128M,memory_limit = 256M,g' -i $PHP_INI

# Must be kept until it is fixed
# https://github.com/zendframework/zend-stdlib/issues/58
RUN sed "s,=> GLOB_BRACE,=> defined('GLOB_BRACE') ? GLOB_BRACE : 0,g" -i /magento/vendor/zendframework/zend-stdlib/src/Glob.php

ADD start.sh /scripts/start.sh
ADD setup.sh /scripts/setup.sh
RUN chmod +x /scripts/start.sh /scripts/setup.sh

#
# Scalability
#
ENV NODES ""

CMD [ "/scripts/start.sh" ]
