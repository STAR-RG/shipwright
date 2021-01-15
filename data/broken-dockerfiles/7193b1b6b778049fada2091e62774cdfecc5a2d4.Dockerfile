FROM alpine:3.6

LABEL description="Project template for Drupal 8 sites built with the Reservoir distribution."
LABEL license="GPL2"
LABEL reservoir_version="1.0.0-alpha2"

# UPDATE APK
RUN   apk update && apk upgrade

# INSTALL GIT & OPENSSH
RUN   apk add git openssh

# INSTALL APACHE2
RUN   apk add apache2 libxml2-dev apache2-utils && \
      mkdir -p /run/apache2/

# INSTALL SQLITE
RUN   apk add sqlite php7-sqlite3 php7-pdo_sqlite php7-pdo_sqlite

# INSTALL PHP7
RUN   apk add libressl curl openssl && \
      apk add php7 php7-apache2 php7-openssl php7-mbstring && \
      apk add php7-apcu php7-intl php7-mcrypt php7-json php7-gd php7-curl && \
      apk add php7-fpm php7-mysqlnd php7-pgsql php7-sqlite3 php7-phar && \
      apk add php7-ctype php7-tokenizer php7-xml php7-pdo php7-pdo_mysql && \
      apk add php7-dom php7-session php7-simplexml php7-opcache php7-zlib

# INSTALL COMPOSER
RUN   cd /tmp && \
      curl -sS https://getcomposer.org/installer | php && \
      mv composer.phar /usr/local/bin/composer

# CLEAR CACHE
RUN   rm -rf /var/cache/apk/*

# LOGGING TO STDOUT + STDERR
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

# SETUP DIRECTORIES
RUN   mkdir -p /app/drupal
RUN   chown -R apache:apache /app

# ADD RESERVOIR COMPOSER.JSON
RUN   curl https://raw.githubusercontent.com/acquia/reservoir-project/8.1.x/composer.json >> /app/drupal/composer.json

# INSTALL RESERVOIR
RUN   cd /app/drupal && \
      composer install

# CREAT FILES DIRECTORY
RUN   mkdir -p /app/drupal/docroot/sites/default/files && \
      chown apache:apache /app/drupal/docroot/sites/default/files && \
      chmod 775 /app/drupal/docroot/sites/default/files

# CREATE SETTINGS.PHP
RUN   cp /app/drupal/docroot/sites/default/default.settings.php /app/drupal/docroot/sites/default/settings.php && \
      chown apache:apache /app/drupal/docroot/sites/default/settings.php && \
      chmod 775 /app/drupal/docroot/sites/default/settings.php

# CONFIGURE APACHE
RUN   sed -i 's/^#ServerName.*/ServerName reservoir-docker/' /etc/apache2/httpd.conf && \
      sed -i 's/#LoadModule\ rewrite_module/LoadModule\ rewrite_module/' /etc/apache2/httpd.conf && \
      sed -i 's/#LoadModule\ deflate_module/LoadModule\ deflate_module/' /etc/apache2/httpd.conf && \
      sed -i 's/#LoadModule\ expires_module/LoadModule\ expires_module/' /etc/apache2/httpd.conf && \
      sed -i "s#^DocumentRoot \".*#DocumentRoot \"/app/drupal/docroot\"#g" /etc/apache2/httpd.conf && \
      sed -i "s#/var/www/localhost/htdocs#/app/drupal/docroot#" /etc/apache2/httpd.conf
ADD   /config/drupal.conf /etc/apache2/conf.d

# PORT
EXPOSE 80

CMD ["/usr/sbin/apachectl", "-DFOREGROUND"]
