# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.18
MAINTAINER Bob Maerten <bob.maerten@gmail.com>

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install locales
ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen cs_CZ.UTF-8
RUN locale-gen de_DE.UTF-8
RUN locale-gen es_ES.UTF-8
RUN locale-gen fr_FR.UTF-8
RUN locale-gen it_IT.UTF-8
RUN locale-gen pl_PL.UTF-8
RUN locale-gen pt_BR.UTF-8
RUN locale-gen ru_RU.UTF-8
RUN locale-gen sl_SI.UTF-8
RUN locale-gen uk_UA.UTF-8

# Install wallabag prereqs
RUN add-apt-repository ppa:nginx/stable \
    && apt-get update \
    && apt-get install -y nginx php5-cli php5-common php5-sqlite \
          php5-curl php5-fpm php5-json php5-tidy php5-gd wget unzip gettext

# Configure php-fpm
RUN echo "cgi.fix_pathinfo = 0" >> /etc/php5/fpm/php.ini
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

COPY www.conf /etc/php5/fpm/pool.d/www.conf

RUN mkdir /etc/service/php5-fpm
COPY php5-fpm.sh /etc/service/php5-fpm/run

RUN mkdir /etc/service/nginx
COPY nginx.sh /etc/service/nginx/run

# Wallabag version
ENV WALLABAG_VERSION 1.9.1-b

# Extract wallabag code
ADD https://github.com/wallabag/wallabag/archive/$WALLABAG_VERSION.zip /tmp/wallabag-$WALLABAG_VERSION.zip
ADD http://wllbg.org/vendor /tmp/vendor.zip

RUN mkdir -p /var/www
RUN cd /var/www \
 && unzip -q /tmp/wallabag-$WALLABAG_VERSION.zip \
 && mv wallabag-$WALLABAG_VERSION wallabag \
 && cd wallabag \
 && unzip -q /tmp/vendor.zip \
 && cp inc/poche/config.inc.default.php inc/poche/config.inc.php \
 && rm -f /tmp/wallabag-$WALLABAG_VERSION.zip /tmp/vendor.zip \
 && rm -rf /var/www/wallabag/install

COPY 99_change_wallabag_config_salt.sh /etc/my_init.d/99_change_wallabag_config_salt.sh

COPY data/poche.sqlite /var/www/wallabag/db/ 
RUN chown -R www-data:www-data /var/www/wallabag \
 && chmod 775 -R /var/www/wallabag \
 && chmod 777 -R /var/www/wallabag/db

# Configure nginx to serve wallabag app
COPY nginx-wallabag /etc/nginx/sites-available/default

EXPOSE 80

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
