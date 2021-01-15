FROM wordpress:php7.2-fpm
RUN apt-get update && apt-get install -y git wget

# install wp-cli
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp && chmod +x /usr/local/bin/wp
RUN apt-get install -y mysql-client

# install phpunit
RUN wget https://phar.phpunit.de/phpunit-5.7.phar -O /usr/local/bin/phpunit && chmod +x /usr/local/bin/phpunit

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN pecl install xdebug-2.6.0

RUN docker-php-ext-install opcache

