FROM php:7.1-apache

# install the additional packages we need
RUN set -ex; \
  \
  apt-get update; \
  apt-get install -y \
    libjpeg-dev \
    libpng12-dev \
    git \
    zip \
  ; \
  rm -rf /var/lib/apt/lists/*; \
  \
  docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
  docker-php-ext-install gd mysqli opcache

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN a2enmod rewrite expires

RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/ \
        && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

COPY  . /var/www/html
WORKDIR /var/www/html

RUN composer config --global --auth http-basic.repo.packagist.com token 43eb54ea86b22dde99cbddcfbda23a4537e05dd0b6cec8eecf4ab76c238e

RUN composer install --prefer-source --no-interaction

RUN ln -s /var/www/html/wp-content/plugins/query-monitor/wp-content/db.php /var/www/html/wp-content/db.php

RUN chown -R www-data:www-data /var/www/html

CMD ["apache2-foreground"]