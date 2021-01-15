FROM ubuntu:latest
MAINTAINER Gabriel Moreira <gabrielmoreira@gmail.com>
ENV HOME /home

# Dependencies
RUN apt-get update && \
    apt-get -yq install \
		supervisor \
		wget git pwgen unzip \
        apache2 libapache2-mod-php5 \
        php5-mysql mysql-server \
		php5-imagick imagemagick \
        php5-curl curl \
        php5-mcrypt \
        php5-gd \
        php-pear \
        php-apc && \
    rm -rf /var/lib/apt/lists/*

# PHP Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Download latest craft
RUN ["/bin/bash", "-c", "curl -L -o /craft.zip https://craftcms.com/latest.zip?accept_license=yes"]

# Unzip craft
RUN unzip /craft.zip -d /var/www && \
    mv /var/www/public/* /var/www/html && \
    rm -f /var/www/html/index.html

# (Dev only)
# RUN apt-get update && apt-get -yq install vim && curl http://j.mp/spf13-vim3 -L -o - | sh

# Fix MySQL (why?)
RUN rm -Rf /var/lib/mysql

# Local includes
ADD includes /

# Default database name
ENV CRAFT_DB_NAME craft

# Default php configurations
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Expose apache port
EXPOSE 80

RUN chmod +x /*.sh && \
    chmod +x /build/*.sh 
    
WORKDIR /var/www/html
CMD /run.sh
