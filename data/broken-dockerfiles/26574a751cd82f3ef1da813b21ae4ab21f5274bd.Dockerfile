FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y
RUN apt-get install -y \
    screen daemontools curl nginx mysql-server git \
    php5-cli php5-json php5-fpm php5-intl php5-mysqlnd php5-curl

RUN apt-get install -y software-properties-common python-software-properties python g++ make
RUN apt-add-repository ppa:chris-lea/node.js
RUN apt-get update -y
RUN apt-get install -y nodejs
RUN npm install -g bower less@2.5

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

ADD . /var/www/tempo

WORKDIR /var/www/tempo

RUN composer install
RUN docker/start_mysql.sh && app/console doctrine:database:create
RUN docker/start_mysql.sh && app/console doctrine:schema:update --force
RUN docker/start_mysql.sh && app/console doctrine:fixtures:load --no-interaction

RUN app/console tempo:js-configuration:dump

RUN npm install
RUN bower install --allow-root
RUN docker/start_mysql.sh && app/console assetic:dump

ADD docker/vhost.conf /etc/nginx/sites-enabled/default

RUN sed -e 's/;daemonize = yes/daemonize = no/' -i /etc/php5/fpm/php-fpm.conf
RUN sed -e 's/;listen\.owner/listen.owner/' -i /etc/php5/fpm/pool.d/www.conf
RUN sed -e 's/;listen\.group/listen.group/' -i /etc/php5/fpm/pool.d/www.conf
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

RUN chmod -R 777 /var/run/screen
RUN chmod -R 777 app/logs app/cache app/data

EXPOSE 80
EXPOSE 8000

ENTRYPOINT ["svscan", "/var/www/tempo/docker/service"]
