# Largely taken from http://blog.stefanxo.com/2014/01/breaking-down-a-dockerfile/
FROM ubuntu:latest
MAINTAINER Ming Chow <mchow@cs.tufts.edu>
RUN apt-get update
RUN apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-client mysql-server apache2 libapache2-mod-php5 python-setuptools vim-tiny php5-mysql sudo
RUN easy_install supervisor
COPY ./database /database
ADD ./scripts/start.sh /start.sh
ADD ./scripts/foreground.sh /etc/apache2/foreground.sh
ADD ./configs/supervisord.conf /etc/supervisord.conf
ADD ./configs/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN rm -rf /var/www/
COPY ./www /var/www
RUN chown -R www-data:www-data /var/www/
RUN chmod 755 /start.sh
RUN chmod 755 /etc/apache2/foreground.sh
RUN mkdir /var/log/supervisor/
RUN mkdir /var/run/sshd
EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
