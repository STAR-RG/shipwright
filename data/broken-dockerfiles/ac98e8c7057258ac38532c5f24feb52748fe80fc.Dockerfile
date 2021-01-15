FROM php:7.0.10-apache

RUN docker-php-ext-install opcache \
 && apt-get update && apt-get install -y libsodium-dev git zip unzip \
 && pecl install libsodium \
 && docker-php-ext-enable libsodium \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

WORKDIR /var/www/html

COPY html/composer.* /var/www/html/
RUN composer install --no-scripts --no-autoloader
COPY html/ /var/www/html/
RUN composer dump-autoload --optimize
