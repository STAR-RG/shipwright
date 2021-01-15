FROM php:7.1-apache

ARG BLD_PKGS="libfreetype6-dev libjpeg62-turbo-dev libpng12-dev postgresql-client libpq-dev libicu-dev"
ARG PHP_EXTS="pdo pdo_pgsql pdo_mysql pgsql gd"

MAINTAINER Jason McCallister <jason@venveo.com>

# install needed items (php extensions)
RUN apt-get update \
    && apt-get install -y $BLD_PKGS \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install $PHP_EXTS \
    && pecl install intl \
    && docker-php-ext-install intl
