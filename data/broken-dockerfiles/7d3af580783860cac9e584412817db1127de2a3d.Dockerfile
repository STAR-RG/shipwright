FROM wordpress:4.9.6-php7.0-apache

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends less libmemcached-dev libxml2-dev libz-dev \
    && docker-php-ext-install soap \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install memcached xdebug \
    && docker-php-ext-enable memcached xdebug \
    && rm -rf /tmp/pear/

RUN { \
      echo ''; \
      echo 'xdebug.remote_enable=1'; \
      echo 'xdebug.remote_port="9000"'; \
    } >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN a2enmod expires proxy proxy_http rewrite

VOLUME /var/www/html

RUN curl -sSL -o /usr/local/bin/wp "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar" \
    && chmod +x /usr/local/bin/wp \
    && mkdir -p /etc/wp-cli \
    && chown www-data:www-data /etc/wp-cli

RUN { \
      echo 'path: /var/www/html'; \
      echo 'url: project.dev'; \
      echo 'apache_modules:'; \
      echo '  - mod_rewrite'; \
    } > /etc/wp-cli/config.yml

RUN echo "export WP_CLI_CONFIG_PATH=/etc/wp-cli/config.yml" > /etc/profile.d/wp-cli.sh

RUN { \
      echo '<IfModule mod_rewrite.c>'; \
      echo '  RewriteEngine On'; \
      echo '  RewriteBase /'; \
      echo '  RewriteRule ^index\.php$ - [L]'; \
      echo '  RewriteCond %{REQUEST_FILENAME} !-f'; \
      echo '  RewriteCond %{REQUEST_FILENAME} !-d'; \
      echo '  RewriteRule . /index.php [L]'; \
      echo '</IfModule>'; \
    } > /usr/src/wordpress/.htaccess

COPY docker-entrypoint.sh /usr/local/bin/
