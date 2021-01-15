FROM php:7.1
MAINTAINER Jelmer Snoeck <jelmer@siphoc.com>

# Install system dependencies
RUN apt-get update
RUN apt-get install -y git-core
RUN apt-get install -y unzip

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('SHA384', 'composer-setup.php') === '55d6ead61b29c7bdee5cccfb50076874187bd9f21f65d8991d46ec5cc90518f447387fb9f76ebae1fbbacf329e583e30') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/bin/composer

# Setup workspace
RUN useradd -ms /bin/bash pdfbundle
USER pdfbundle
RUN mkdir /home/pdfbundle/package
WORKDIR /home/pdfbundle/package

# Install dependencies
ADD composer.json .
RUN composer install
