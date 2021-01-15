FROM ubuntu:16.04

MAINTAINER Gildásio Júnior (gjuniioor@protonmail.com)

# update package list
RUN apt-get update

# install curl and git
RUN apt-get install -y curl git

# install apache
RUN apt-get install -y apache2

# install php
RUN apt-get -y install php7.0 mcrypt php7.0-mcrypt php-mbstring php-pear php7.0-dev php7.0-xml
RUN apt-get install -y libapache2-mod-php7.0

# install pre requisites
RUN apt-get update
RUN apt-get install -y apt-transport-https
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql mssql-tools
RUN apt-get install -y unixodbc-utf16
RUN apt-get install -y unixodbc-dev-utf16

# install driver sqlsrv
RUN pecl install sqlsrv
RUN echo "extension=sqlsrv.so" >> /etc/php/7.0/apache2/php.ini
RUN pecl install pdo_sqlsrv
RUN echo "extension=pdo_sqlsrv.so" >> /etc/php/7.0/apache2/php.ini

# load driver sqlsrv
RUN echo "extension=/usr/lib/php/20151012/sqlsrv.so" >> /etc/php/7.0/apache2/php.ini
RUN echo "extension=/usr/lib/php/20151012/pdo_sqlsrv.so" >> /etc/php/7.0/apache2/php.ini
RUN echo "extension=/usr/lib/php/20151012/sqlsrv.so" >> /etc/php/7.0/cli/php.ini
RUN echo "extension=/usr/lib/php/20151012/pdo_sqlsrv.so" >> /etc/php/7.0/cli/php.ini

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# install ODBC Driver
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql
RUN apt-get install -y mssql-tools
RUN apt-get install -y unixodbc-dev
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN exec bash

# install locales
RUN apt-get install -y locales && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

EXPOSE 80

WORKDIR /var/www/html/

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
