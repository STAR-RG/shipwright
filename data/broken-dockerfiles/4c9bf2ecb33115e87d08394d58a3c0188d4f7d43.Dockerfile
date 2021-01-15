FROM php:5.6 
MAINTAINER Krzysztof Kawalec <kf.kawalec@gmail.com> 
RUN apt-get update && \ 
    DEBIAN_FRONTEND=noninteractive apt-get install -y \ 
        openssh-client \ 
        libfreetype6-dev \ 
        libjpeg62-turbo-dev \ 
        libmcrypt-dev \ 
        libpng12-dev \ 
        libcurl4-openssl-dev \ 
        libldap2-dev \ 
        libpq-dev \ 
        curl \ 
        libtidy* \ 
        git \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/* 
 
# PHP Extensions 
RUN docker-php-ext-install \ 
    mcrypt \ 
    mbstring \ 
    curl \ 
    json \ 
    mysql \ 
    mysqli \ 
    pgsql \ 
    pdo_mysql \ 
    pdo_pgsql \ 
    exif \ 
    tidy \ 
    zip \ 
      && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \ 
        && docker-php-ext-install gd \ 
        && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \ 
        && docker-php-ext-install ldap 

# Xdebug
RUN pecl install -o -f xdebug-2.5.5 \ 
    && rm -rf /tmp/* \ 
    && docker-php-ext-enable xdebug 

# NodeJS
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean

RUN pecl install -o -f redis-2.2.8 \ 
    && rm -rf /tmp/* \ 
    && docker-php-ext-enable redis 
   
# Memory Limit 
RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini 
 
# Time Zone 
RUN echo "date.timezone=Europe/Warsaw" > $PHP_INI_DIR/conf.d/date_timezone.ini 
 
VOLUME /root/composer 
 
# Environmental Variables 
ENV COMPOSER_HOME /root/composer 
 
# Install Composer 
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \ 
  composer selfupdate 
     
# Goto temporary directory. 
WORKDIR /tmp 
 
# Run composer and phpunit installation. 
RUN composer require "phpunit/phpunit=5.*" --prefer-source --no-interaction && \ 
    ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit 
 
# Run composer and codesniffer installation. 
RUN composer require "squizlabs/php_codesniffer=*" --prefer-source --no-interaction && \ 
    ln -s /tmp/vendor/bin/phpcs /usr/local/bin/phpcs 
 
RUN php --version 
RUN composer --version 
RUN phpunit --version 
RUN phpcs --version 