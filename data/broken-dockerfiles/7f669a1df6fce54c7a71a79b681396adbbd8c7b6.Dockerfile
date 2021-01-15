FROM php:5.6-apache

RUN apt-get update && apt-get install git zip -y
RUN a2enmod rewrite && \
  docker-php-ext-install pdo mbstring tokenizer 
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
  php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
  php composer-setup.php && \
  php -r "unlink('composer-setup.php');" && \
  mv composer.phar /usr/local/bin/composer && \
  composer create-project unicalabs/agrippa /var/www/html/agrippa

RUN echo '<VirtualHost *:80>\n\
    ServerAdmin webmaster@localhost\n\
    DocumentRoot /var/www/html/agrippa/public\n\
    <Directory /var/www/html/agrippa>\n\
        AllowOverride All\n\
    </Directory>\n\
    ErrorLog ${APACHE_LOG_DIR}/error.log\n\
    CustomLog ${APACHE_LOG_DIR}/access.log combined\n\
</VirtualHost>'\
> /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html/agrippa
RUN touch storage/database.sqlite
RUN chown -R www-data:www-data storage bootstrap/cache
RUN php artisan migrate
