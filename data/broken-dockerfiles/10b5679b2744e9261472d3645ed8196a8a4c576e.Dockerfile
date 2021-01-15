FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y software-properties-common

RUN LANG=C.UTF-8 add-apt-repository ppa:ondrej/php5-5.6 && \
    apt-get update && \
    apt-get install -y php5-cli php5-fpm libzmq3-dev libzmq3 php5-dev php-pear pkg-config
RUN apt-get install -y php5-apcu php5-pgsql php5-curl
RUN yes "" | pecl install zmq-beta && \
    /bin/sh -c 'echo extension=zmq.so > /etc/php5/mods-available/zmq.ini' && \
    php5enmod zmq

EXPOSE 9000
COPY ./config/php-fpm.conf /etc/php5/fpm/php-fpm.conf
CMD ["php5-fpm"]

COPY . /src/
