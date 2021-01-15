FROM ubuntu:trusty
MAINTAINER cedric@zestprod.com
RUN apt-get update
RUN apt-get install -y apache2

RUN sudo apt-get install -y software-properties-common \
  && add-apt-repository ppa:ondrej/php \
  && apt-get update

RUN apt-get install -y --force-yes \
  wget \
  php5.6 \
  php5.6-mysql \
  php5.6-ldap \
  php5.6-xmlrpc \
  curl \
  php5.6-curl \
  php5.6-gd \
  php5.6-mbstring \
  php5.6-simplexml \
  php5.6-xml \
  php5.6-apcu \
  php5.6-imap

RUN a2enmod rewrite && service apache2 stop
WORKDIR /var/www/html
COPY start.sh /opt/
RUN chmod +x /opt/start.sh
RUN usermod -u 1000 www-data
CMD /opt/start.sh
EXPOSE 80
