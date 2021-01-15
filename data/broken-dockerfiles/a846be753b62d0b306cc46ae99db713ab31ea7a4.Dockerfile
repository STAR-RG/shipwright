FROM php:5.6-apache

MAINTAINER Fabian Fuelling <docker@fabfuel.de>

# Install modules
RUN apt-get update; apt-get install -y php5-dev git libpq-dev libmemcached-dev libicu-dev wget && apt-get clean
RUN docker-php-ext-install opcache mbstring pdo_mysql pdo_pgsql intl pgsql
RUN pecl install -f apcu mongo redis memcached xdebug

# checkout, compile and install recent Phalcon extension
RUN cd ~; git clone https://github.com/phalcon/cphalcon -b master --single-branch; cd ~/cphalcon/build; ./install; rm -rf ~/cphalcon

# enable Apache's mod_rewrite and change document root to: /var/www/html/public
RUN cd /etc/apache2/mods-enabled && ln -s ../mods-available/rewrite.load rewrite.load
RUN sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html/public#g' /etc/apache2/apache2.conf
RUN sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html/public#g' /etc/apache2/sites-available/*.conf

# install NewRelic
RUN (wget -O - https://download.newrelic.com/548C16BF.gpg | apt-key add - && \
  sh -c 'echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list' && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y newrelic-php5 && \
  apt-get clean) && \
  ln -s /usr/lib/newrelic-php5/agent/x64/newrelic-20131226.so /usr/local/lib/php/extensions/no-debug-non-zts-20131226/newrelic.so && \
  cp /etc/php5/mods-available/newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini

# Expose NewRelic config vars 
ENV NEWRELIC_LICENSE **None**
ENV NEWRELIC_APPNAME Docker PHP Application

# add config and dummy content
COPY var/www /var/www/html
COPY etc /usr/local/etc

# add entrypoint run script
ADD run.sh /usr/local/bin/run
ENTRYPOINT ["/usr/local/bin/run"]

CMD ["apache2-foreground"]
