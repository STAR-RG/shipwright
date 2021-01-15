FROM ubuntu:latest 
MAINTAINER cameron Meindl <cmeindl@gmail.com>
#install the Pre Reqs and Apache
RUN apt-get update && apt-get -yq install php5 php5-dev php-pear php5-gd php5-mysql php5-curl mysql-client-5.5 libmysqlclient-dev \
 	apache2 subversion unrar-free lame python-software-properties mediainfo supervisor

# need to add your Newznab plus SVN Password and user here http://newznab4win.blogspot.com.au/2013/01/installing-newznab.html

ENV nn_user user 
ENV nn_pass password
ENV php_timezone Australia/Sydney 
ENV path /:/var/www/html/www/
# add the Config to Apache
ADD ./newznab.conf /etc/apache2/sites-available/newznab.conf
RUN mkdir /var/www/newznab/
# pull NNab plus from SVN - Note you need the username and password for Svn Above
RUN svn co --username $nn_user --password $nn_pass svn://svn.newznab.com/nn/branches/nnplus /var/www/newznab/
RUN chmod 777 /var/www/newznab/www/lib/smarty/templates_c && \
chmod 777 /var/www/newznab/www/covers/movies && \
chmod 777 /var/www/newznab/www/covers/anime  && \
chmod 777 /var/www/newznab/www/covers/music  && \
chmod 777 /var/www/newznab/www  && \
chmod 777 /var/www/newznab/www/install  && \
chmod 777 /var/www/newznab/nzbfiles/ 

#fix the config files for PHP
RUN sed -i "s/max_execution_time = 30/max_execution_time = 120/" /etc/php5/cli/php.ini  && \
sed -i "s/memory_limit = -1/memory_limit = 1024M/" /etc/php5/cli/php.ini  && \
echo "register_globals = Off" >> /etc/php5/cli/php.ini  && \
echo "date.timezone =$php_timezone" >> /etc/php5/cli/php.ini  && \
sed -i "s/max_execution_time = 30/max_execution_time = 120/" /etc/php5/apache2/php.ini  && \
sed -i "s/memory_limit = -1/memory_limit = 1024M/" /etc/php5/apache2/php.ini  && \
echo "register_globals = Off" >> /etc/php5/apache2/php.ini  && \
echo "date.timezone =$php_timezone" >> /etc/php5/apache2/php.ini  && \
sed -i "s/memory_limit = 128M/memory_limit = 1024M/" /etc/php5/apache2/php.ini

# Disable Default site and enable newznab site - Restart Apache here to confirm your newznab.conf is valid in case you changed it
RUN a2dissite 000-default.conf
RUN a2ensite newznab
RUN a2enmod rewrite
RUN service apache2 restart

# add newznab config file - This needs to be edited
ADD ./config.php /var/www/newznab/www/config.php
RUN chmod 777 /var/www/newznab/www/config.php

#add newznab processing script
ADD ./newznab.sh /newznab.sh
RUN chmod 755 /*.sh

#Setup supervisor to start Apache and the Newznab scripts to load headers and build releases

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup NZB volume this will need to be mapped locally using -v command so that it can persist.
EXPOSE 80
VOLUME /nzb
WORKDIR /var/www/html/www/
#kickoff Supervisor to start the functions
CMD ["/usr/bin/supervisord"]
