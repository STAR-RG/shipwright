FROM php:7.1-apache
MAINTAINER Kosta Harlan <kosta@savaslabs.com>

COPY docker/php.ini /usr/local/etc/php/
COPY source/ /var/www/html/

RUN a2enmod rewrite

RUN apt-get update -o Retries=25 \
    && apt-get upgrade -y \
    && apt-get install -my -o Retries=25 \
    wget \
    unzip \
    git \
    sqlite3 \
    && apt-get clean

RUN cd $HOME && \
    wget http://getcomposer.org/composer.phar && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    wget https://phar.phpunit.de/phpunit.phar && \
    chmod +x phpunit.phar && \
    mv phpunit.phar /usr/local/bin/phpunit

RUN sed -i -e 's/\/var\/www\/html/\/var\/www\/html\/public/' /etc/apache2/sites-enabled/000-default.conf

RUN mkdir /var/www/.composer; chown www-data:www-data /var/www/.composer; chown -R www-data:www-data /var/www/html
WORKDIR /var/www/html
USER www-data
RUN composer global require "hirak/prestissimo:^0.3"
RUN composer install -n --prefer-dist

USER root

EXPOSE 80
