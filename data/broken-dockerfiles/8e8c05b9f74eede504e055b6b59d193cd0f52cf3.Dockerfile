FROM php:5-apache

RUN apt-get update \
    && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng12-dev \
        sqlite3 libsqlite3-dev \
        libssl-dev \
    && pecl install mongo \
    && docker-php-ext-install -j$(nproc) iconv gd pdo pdo_sqlite \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && a2enmod rewrite

RUN echo "extension=mongo.so" > /usr/local/etc/php/conf.d/mongo.ini

COPY docker-config.php /var/www/html/custom/config.php
# Next branch configuration
COPY docker-config.php /var/www/html/config/config.php
COPY src /var/www/html/
RUN chmod 777 -R storage config
VOLUME /var/www/html/storage
