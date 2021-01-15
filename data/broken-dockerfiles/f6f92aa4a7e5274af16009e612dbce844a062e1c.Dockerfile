FROM php:5.6-apache

RUN apt-get update && apt-get install -y \
        php5-mysql php5-curl \
    && docker-php-ext-install mysql mysqli pdo pdo_mysql

RUN echo "date.timezone=${PHP_TIMEZONE:-UTC}" > $PHP_INI_DIR/conf.d/date_timezone.ini

RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf

COPY config/symfony.conf /etc/apache2/sites-enabled
COPY php-br /var/www/html/
