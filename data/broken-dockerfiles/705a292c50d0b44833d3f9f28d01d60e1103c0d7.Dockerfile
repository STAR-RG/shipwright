FROM dockerfiles/centos-lamp
MAINTAINER Frédéric Langlade-Bellone <fred@parapluie.org>

RUN yum -y install git php-cli php-mysql php-process php-devel php-gd php-pecl-apc php-pecl-json php-mbstring

RUN rm /etc/httpd/conf.d/welcome.conf
RUN mkdir /var/repo
ADD files/apache_vhost.conf /etc/httpd/conf.d/phabricator.conf
ADD files/supervisord.conf /etc/
ADD files/check_db.sh /opt/check_db.sh

RUN git clone git://github.com/facebook/libphutil.git /var/www/libphutil
RUN git clone git://github.com/facebook/arcanist.git /var/www/arcanist
RUN git clone git://github.com/facebook/phabricator.git /var/www/phabricator
RUN sed -i -e "s/apc.stat=1/apc.stat=0/" /etc/php.d/apc.ini

VOLUME ["/var/lib/mysql","/var/repo"]
CMD ["supervisord", "-n"]
