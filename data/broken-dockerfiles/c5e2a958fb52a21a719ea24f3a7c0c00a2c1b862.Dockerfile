FROM php:7.0-apache
COPY . /var/www
RUN cp -rf /var/www/public/. /var/www/html
RUN docker-php-source extract \
    && apt-get update \
    && apt-get install libmcrypt-dev libldap2-dev nano -y \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install ldap pdo pdo_mysql bcmath \
    && a2enmod rewrite \
    && a2enmod ssl \
    && docker-php-source delete
RUN cd /var/www/ && php composer.phar install \
    && chmod 777 -Rf /var/www/storage
