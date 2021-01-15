FROM php:7.0.4-apache
RUN php -r "readfile('http://77g5xb.com2.z0.glb.clouddn.com/composer-setup.php');" > composer-setup.php \
    && php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) === '92102166af5abdb03f49ce52a40591073a7b859a86e8ff13338cf7db58a19f7844fbc0bb79b2773bf30791e935dbd938') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

RUN apt-get update && apt-get install -y libmcrypt-dev git zlib1g-dev
RUN docker-php-ext-install mbstring mcrypt pdo_mysql zip

WORKDIR /tmp/composer-install
ADD ./composer.json composer.json
ADD ./composer.lock composer.lock
RUN composer install --no-dev

RUN sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/webapp/public#' /etc/apache2/apache2.conf
COPY . /var/www/webapp
RUN chown www-data -R /var/www/webapp/storage
RUN cp -r /tmp/composer-install/vendor /var/www/webapp

WORKDIR /var/www/webapp

CMD bash /var/www/webapp/start-up.sh
