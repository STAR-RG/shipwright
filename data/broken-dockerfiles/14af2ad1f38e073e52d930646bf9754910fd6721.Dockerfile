FROM php:5.6-apache

RUN apt-get update && \
	echo 'mysql-server mysql-server/root_password password local' | debconf-set-selections  && \
	echo 'mysql-server mysql-server/root_password_again password local' | debconf-set-selections && \
	apt-get -y install  mysql-server-5.5 && apt-get clean
RUN /etc/init.d/mysql restart && mysqladmin --password=local  create jackknife
RUN docker-php-ext-install mysqli && ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock

COPY . /var/www/html/
WORKDIR /var/www/html
RUN mv base.config.php eve.config.php && chown www-data /var/www/html && \
	/etc/init.d/mysql start && /etc/init.d/apache2 start && \
	curl -b PHPSESSID=foo "localhost/Installer.php?db=1&t=1" > /dev/null && \
	(for i in 0 1 2 3 4 5 6 7 8 9 ; do curl -b PHPSESSID=foo "localhost/Installer.php?sql=$i&t1" > /dev/null ; done)  && \
	curl -b PHPSESSID=foo "localhost/Installer.php?sql=lock&t=1" > /dev/null && \
	/etc/init.d/mysql stop && /etc/init.d/apache2 stop


CMD /etc/init.d/mysql restart && apache2-foreground
