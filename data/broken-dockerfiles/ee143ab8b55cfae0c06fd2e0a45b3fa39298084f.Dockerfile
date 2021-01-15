FROM php:5.6-apache

# set needed variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

# Install extensions
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        subversion \
        wget \
        git \
        libmagickwand-dev \
        libldb-dev \
        libc-client-dev \
        libkrb5-dev \
        libpq-dev \
        libicu-dev \
        libffi-dev \
        openjdk-7-jre \
        libsqlite3-dev \
        libyaml-dev \
        zlib1g-dev \
        libldap2-dev

# Fix LDAP lib path problem
RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap_r-2.4.so.2 /usr/lib/libldap_r-2.4.so.2

RUN docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd gettext ldap pdo_mysql pdo_pgsql pdo_sqlite intl zip

# Other extensions
RUN pecl install imagick-3.4.1 \
    && docker-php-ext-enable imagick

RUN pecl install apcu-4.0.10 \
    && docker-php-ext-enable apcu

# Configuration file extension
RUN pecl install yaml \
    && docker-php-ext-enable yaml


# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini


# Generate recomended settings
COPY conf/php.ini /usr/local/etc/php/

# Enable rewrite
RUN a2enmod rewrite

# Install Cacic
ADD . /usr/src/cacic
RUN chown -R www-data.www-data /usr/src/cacic
RUN rm -rf /var/www/html && ln -s /usr/src/cacic/web /var/www/html

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80

VOLUME [ "/usr/src/cacic/web/downloads" ]

CMD ["php", "/usr/src/cacic/entrypoint.php"]
