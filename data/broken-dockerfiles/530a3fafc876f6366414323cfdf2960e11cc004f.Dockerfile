FROM php:fpm

MAINTAINER Luu Trong Hieu <tronghieu.luu@gmail.com>

WORKDIR /var/www

ENV PHPIZE_DEPS autoconf file g++ gcc libc-dev make pkgconf re2c php7-dev php7-pear \
        yaml-dev pcre-dev zlib-dev libmemcached-dev cyrus-sasl-dev

RUN apt-get update -yqq

RUN apt install -y curl software-properties-common gnupg \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN apt-get install git nodejs libcurl4-gnutls-dev libicu-dev \
    libmcrypt-dev libvpx-dev libjpeg-dev libpng-dev libxpm-dev \
    zlib1g-dev libfreetype6-dev libxml2-dev libexpat1-dev libbz2-dev \
    libgmp3-dev libldap2-dev unixodbc-dev libpq-dev libsqlite3-dev \
    libaspell-dev libsnmp-dev libpcre3-dev libtidy-dev gettext -yqq

RUN docker-php-ext-install mbstring pdo_mysql curl json intl gd xml zip bz2 opcache

RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --filename=composer --install-dir=/usr/bin \
    && php -r "unlink('composer-setup.php');" \
    && chmod +x /usr/bin/composer