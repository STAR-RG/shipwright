FROM ubuntu:15.04

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-get install -y nginx curl nodejs npm ruby libnotify-bin
RUN apt-get install -y php5-fpm php5-mcrypt php5-pgsql

# Configure Nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
ADD nginx/sites-enabled/ /etc/nginx/sites-enabled

# Configure PHP FPM
ENV PHP_EXT_DIR  /usr/lib/php5/20131226
ENV PHP_INI_DIR  /etc/php5/fpm
ENV PHP_INI      ${PHP_INI_DIR}/php.ini

RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;clear_env = no/clear_env = no/" /etc/php5/fpm/pool.d/www.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" $PHP_INI
RUN sed -i "s/display_errors = Off/display_errors = On/" $PHP_INI
RUN sed -i "s/;date.timezone =/date.timezone = Europe\/Berlin/" $PHP_INI
RUN php5enmod mcrypt

# Install composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Laravel
RUN composer global require "laravel/installer=~1.2"
ENV PATH /root/.composer/vendor/bin:$PATH

# Install Gulp
RUN ln -s /usr/bin/nodejs /usr/local/bin/node
RUN npm install -g gulp browserify

# Install Ruby Sass
RUN gem install sass

WORKDIR /code/app

RUN useradd -d /code/app -u 1000 www && \
    sed -i 's/www-data/www/g' /etc/nginx/nginx.conf && \
    sed -i "s/www-data/www/g" /etc/php5/fpm/pool.d/www.conf && \
    sed -i "s/www-data/www/g" /etc/php5/fpm/pool.d/www.conf && \
    chown -R www:www \
        /var/log/nginx \
        /code/app

CMD ["../startup.sh"]
