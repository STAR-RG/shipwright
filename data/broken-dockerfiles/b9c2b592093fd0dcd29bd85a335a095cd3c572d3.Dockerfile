FROM php:cli

RUN mkdir /opt/collection-json.php

VOLUME ["/opt/collection-json.php"]

WORKDIR /opt/collection-json.php

ENV PATH $PATH:/opt/vendor/bin

RUN cd .. \
  && php -r "readfile('https://getcomposer.org/installer');" | php \
  && apt-get update && apt-get install -y zlib1g-dev git \
  && docker-php-ext-install zip \
  && pecl install xdebug \
  && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini \
  && php composer.phar require --prefer-source phpunit/phpunit zerkalica/phpcs:dev-master
