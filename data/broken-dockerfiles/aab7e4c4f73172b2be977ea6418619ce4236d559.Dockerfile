FROM php:7.1.12-fpm

ENV LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update -qq && apt-get install -qq curl \
  && curl -fsSL https://deb.nodesource.com/setup_8.x | bash - \
  && apt-get install -qq --no-install-recommends \
    nginx \
    supervisor \
    build-essential \
    nodejs \
    git \
    less \
    mysql-client \
    libjpeg-dev \
    libpng-dev \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure gd --with-jpeg-dir=/usr --with-png-dir=/usr \
  && docker-php-ext-install gd mysqli opcache zip \
  && pecl install apcu apcu_bc-beta \
  && docker-php-ext-enable --ini-name docker-php-ext-apcu.ini apcu apc \
  # Composer
  && curl -fsSLo composer-setup.php https://getcomposer.org/installer \
  && echo '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061 composer-setup.php' | sha384sum -c - \
  && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
  && rm composer-setup.php \
  && composer config -g repos.packagist composer https://packagist.jp \
  && composer global require hirak/prestissimo

RUN { \
    echo '[supervisord]'; \
    echo 'nodaemon=true'; \
    echo '[program:nginx]'; \
    echo 'command=/usr/sbin/nginx -g "daemon off;"'; \
    echo 'stdout_logfile=/dev/stdout'; \
    echo 'stdout_logfile_maxbytes=0'; \
    echo 'stderr_logfile=/dev/stderr'; \
    echo 'stderr_logfile_maxbytes=0'; \
    echo '[program:php-fpm]'; \
    echo 'command=/usr/local/sbin/php-fpm'; \
    echo 'stdout_logfile=/dev/stdout'; \
    echo 'stdout_logfile_maxbytes=0'; \
    echo 'stderr_logfile=/dev/stderr'; \
    echo 'stderr_logfile_maxbytes=0'; \
  } > /etc/supervisor/conf.d/supervisord.conf \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log \
  && { \
    echo 'upstream php-fpm {'; \
    echo '  server unix:/run/php-fpm.sock max_fails=0;'; \
    echo '  keepalive 2;'; \
    echo '}'; \
    echo 'server {'; \
    echo '  listen 80 default_server;'; \
    echo '  server_name _;'; \
    echo '  root /app/public;'; \
    echo '  index index.php index.html index.htm;'; \
    echo '  location ~ \.php$ {'; \
    echo '    include snippets/fastcgi-php.conf;'; \
    echo '    fastcgi_pass php-fpm;'; \
    echo '    fastcgi_keep_conn on;'; \
    echo '  }'; \
    echo '  location / {'; \
    echo '    try_files $uri $uri/ /index.php?$args;'; \
    echo '  }'; \
    echo '}'; \
  } > /etc/nginx/sites-available/default \
  && { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini \
  && sed -i 's|^listen = \[::\]:9000$|listen = /run/php-fpm.sock\nlisten.owner = www-data\nlisten.group = www-data|g' /usr/local/etc/php-fpm.d/zz-docker.conf

EXPOSE 80
CMD ["/usr/bin/supervisord"]
