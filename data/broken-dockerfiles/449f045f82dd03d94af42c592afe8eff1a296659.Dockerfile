#Drupal

FROM ubuntu:12.04
 
RUN apt-get update

#Prevent daemon start during install
RUN	echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

#Supervisord
RUN apt-get install -y supervisor && mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#SSHD
RUN apt-get install -y openssh-server && mkdir /var/run/sshd && echo 'root:root' |chpasswd

#Utilities
RUN apt-get install -y vim less ntp net-tools inetutils-ping curl git

#All pkgs required by Drupal
RUN apt-get -y install git mysql-client mysql-server apache2 libapache2-mod-php5 pwgen python-setuptools vim-tiny php5-mysql php-apc php5-gd php5-memcache memcached php-pear mc varnish

#Drush
RUN pear channel-discover pear.drush.org && pear install drush/drush

#Install Drupal
RUN rm -rf /var/www/ ; cd /var ; drush dl drupal ; mv /var/drupal*/ /var/www/
RUN chmod a+w /var/www/sites/default ; mkdir /var/www/sites/default/files ; chown -R www-data:www-data /var/www/

#Varnish
ADD ./drupal.vcl /etc/varnish/drupal.vcl
ADD ./status.php /var/www/status.php

#Cleanup agt-get to reduce disk
RUN apt-get clean

#Configurations

#Apache
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-available/default
RUN a2enmod rewrite vhost_alias
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

#Supervisor starts everything
ADD	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#MySql
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
RUN supervisord & sleep 3 && mysql -e "CREATE DATABASE drupal; GRANT ALL ON drupal.* TO 'drupal'@'localhost';" && cd /var/www/ && drush site-install standard -y --account-name=admin --account-pass=admin --db-url="mysql://drupal@localhost:3306/drupal" && cd /var/www && drush dl varnish memcache && drush en varnish memcache memcache_admin -y && drush vset cache 1 && drush vset page_cache_maximum_age 3600 && drush vset varnish_version 3 && mysqladmin shutdown

#Drupal Settings
ADD ./settings.php.append /tmp/settings.php.append
RUN cat /tmp/settings.php.append >> /var/www/sites/default/settings.php

EXPOSE 80 22 6081


