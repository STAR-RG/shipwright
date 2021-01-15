FROM resin/rpi-raspbian:latest
MAINTAINER Søren Schmidt Kriegbaum "comzone5@gmail.com"
#RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" >> /etc/apt/sources.list

RUN apt-get -y update 

RUN dpkg-divert --local --rename --add /sbin/initctl
#RUN ln -s /bin/true /sbin/initctl

RUN apt-get install -y locales dialog
RUN locale-gen en_US en_US.UTF-8
RUN dpkg-reconfigure -f noninteractive locales

RUN echo "mysql-server-5.5 mysql-server/root_password password root123" | debconf-set-selections
RUN echo "mysql-server-5.5 mysql-server/root_password_again password root123" | debconf-set-selections
RUN echo "mysql-server-5.5 mysql-server/root_password seen true" | debconf-set-selections
RUN echo "mysql-server-5.5 mysql-server/root_password_again seen true" | debconf-set-selections

RUN apt-get install -y supervisor apache2 php5 php5-gd php-xml-parser php5-intl php5-sqlite mysql-server-5.5 smbclient curl libcurl3 php5-mysql php5-curl bzip2 wget vim openssl ssl-cert sharutils

RUN wget -q -O - http://download.owncloud.org/community/owncloud-latest.tar.bz2 | tar jx -C /var/www/;chown -R www-data:www-data /var/www/owncloud

RUN mkdir /etc/apache2/ssl

ADD resources/cfgmysql.sh /tmp/
RUN chmod +x /tmp/cfgmysql.sh
RUN /tmp/cfgmysql.sh
RUN rm /tmp/cfgmysql.sh

ADD resources/001-owncloud.conf /etc/apache2/sites-available/
ADD resources/000-default.conf /etc/apache2/sites-available/
ADD resources/lamp.conf /etc/supervisor/conf.d/

ADD resources/start.sh /

RUN a2ensite 001-owncloud.conf
RUN a2ensite 000-default.conf
RUN a2enmod rewrite ssl

#RUN chown -R www-data:www-data /var/www/owncloud
RUN chmod +x /start.sh

EXPOSE 80
EXPOSE 443

CMD ["/start.sh"]
