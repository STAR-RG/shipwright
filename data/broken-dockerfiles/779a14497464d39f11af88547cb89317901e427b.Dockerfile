FROM ubuntu:14.04
MAINTAINER Frederic Guillot <fred@kanboard.net>

RUN apt-get update && apt-get install -y apache2 php5 php5-gd php5-sqlite git curl && apt-get clean
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && a2enmod rewrite
RUN sed -ri 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
RUN curl -sS https://getcomposer.org/installer | php -- --filename=/usr/local/bin/composer
RUN cd /var/www && git clone --depth 1 https://github.com/fguillot/kanboard.git
RUN cd /var/www/kanboard && composer --prefer-dist --no-dev --optimize-autoloader --quiet install
RUN rm -rf /var/www/html && mv /var/www/kanboard /var/www/html
RUN chown -R www-data:www-data /var/www/html/data

VOLUME /var/www/html/data

EXPOSE 80

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

CMD /usr/sbin/apache2ctl -D FOREGROUND
