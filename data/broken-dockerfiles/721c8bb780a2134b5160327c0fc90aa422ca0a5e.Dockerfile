FROM debian
ADD dev/sources.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get install --no-install-recommends php5 -y --force-yes
RUN apt-get install php5-cli -y --force-yes
RUN apt-get install curl -y --force-yes
RUN apt-get install php5-mcrypt -y --force-yes
RUN echo "extension=mcrypt.so" > /etc/php5/cli/conf.d/10-mcrypt.ini
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer
ADD . /goku
WORKDIR /goku
RUN composer update --verbose --prefer-dist
CMD php artisan