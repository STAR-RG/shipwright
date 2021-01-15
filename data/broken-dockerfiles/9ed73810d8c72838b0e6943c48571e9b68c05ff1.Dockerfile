FROM php:7.1-apache

RUN apt-get update \
        && apt-get install -y ssl-cert libicu-dev libxml2-dev libmcrypt-dev libcurl4-gnutls-dev libfreetype6-dev libjpeg62-turbo-dev libpng12-dev \
        && docker-php-ext-install -j$(nproc) intl xml soap mcrypt opcache pdo pdo_mysql mysqli mbstring xmlrpc curl \
        && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-install -j$(nproc) gd

RUN a2enmod ssl && a2ensite default-ssl
