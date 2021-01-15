ARG php_version

FROM php:${php_version}-cli

RUN apt-get update && apt-get install -y \
    curl \
    libzip-dev \
    zip \
&& docker-php-ext-install \
    zip \
    pdo_mysql \
&& pecl install \
    xdebug-2.9.2 \
&& docker-php-ext-enable \
    xdebug

COPY . /var/php
WORKDIR /var/php

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer update --prefer-dist --no-interaction