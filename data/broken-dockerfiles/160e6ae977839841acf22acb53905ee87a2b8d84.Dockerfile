FROM phusion/baseimage:0.9.16
MAINTAINER Lingliang Zhang <lingliangz@gmail.com>

# PHP 5.6
RUN apt-get update
RUN apt-get -y upgrade

# Basic Requirements
RUN apt-get -y install nginx php5-mysql php-apc curl unzip php5 php5-fpm

# Wordpress Requirements
RUN apt-get -y install php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl

# Upgrade to PHP 5.6
RUN echo "deb http://ppa.launchpad.net/ondrej/php5-5.6/ubuntu trusty main" >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-key E5267A6C && \
    apt-get update
RUN apt-get -y install php5 php5-gd php5-ldap \
    php5-sqlite php5-pgsql php-pear php5-mysql \
    php5-mcrypt php5-xmlrpc php5-fpm

# nginx config
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# HHVM install
RUN curl http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
RUN echo deb http://dl.hhvm.com/ubuntu trusty main | sudo tee /etc/apt/sources.list.d/hhvm.list
RUN apt-get update && apt-get install -y hhvm

# nginx site conf
ADD ./nginx-site.conf /etc/nginx/sites-available/default

# Install Wordpress
ADD WordPress/ /usr/share/nginx/www
ADD wp-config.php /usr/share/nginx/www/wp-config.php
RUN chown -R www-data:www-data /usr/share/nginx/www

# Start the services
RUN mkdir /etc/service/nginx
ADD nginx.sh /etc/service/nginx/run

RUN mkdir /etc/service/hhvm
ADD hhvm.sh /etc/service/hhvm/run

RUN mkdir /etc/service/php5-fpm
ADD php5-fpm.sh /etc/service/php5-fpm/run

RUN sudo /usr/share/hhvm/install_fastcgi.sh

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# HHVM config
RUN sed -i -e"s/9000/8000/" /etc/hhvm/server.ini /etc/nginx/hhvm.conf
# PHP5-FPM config
RUN sed -i '/daemonize /c \
  daemonize = no' /etc/php5/fpm/php-fpm.conf
RUN sed -i '/clear_env /c \
  clear_env = no' /etc/php5/fpm/pool.d/www.conf

# private expose
EXPOSE 80

# Start the custom run script (fixes hanging bug)
ADD ./my_init /my_init
RUN chmod 755 /my_init

CMD ["/my_init"]
