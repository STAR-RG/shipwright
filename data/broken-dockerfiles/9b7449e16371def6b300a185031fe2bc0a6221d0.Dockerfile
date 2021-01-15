FROM ubuntu:12.04

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade --yes

# php
RUN apt-get install --quiet --yes python-software-properties
RUN add-apt-repository ppa:ondrej/php5
RUN apt-get update
RUN apt-get install --quiet --yes php5

# composer
RUN apt-get install --quiet --yes curl php5-cli
RUN cd /usr/local/bin/ && curl --silent https://getcomposer.org/installer | php

# phpunit
RUN apt-get install --quiet --yes php-pear
RUN pear config-set auto_discover 1
RUN pear install pear.phpunit.de/PHPUnit

# json-c
RUN apt-get install --quiet --yes git
RUN d=/usr/local/src/json-c && git clone https://github.com/json-c/json-c $d && cd $d && git checkout 06450206c4f3de4af8d81bb6d93e9db1d5fedec1
RUN apt-get install --quiet --yes autoconf libtool make
RUN cd /usr/local/src/json-c && ./autogen.sh && ./configure && make && make install

# zephir
RUN d=/usr/local/src/zephir && git clone https://github.com/phalcon/zephir $d && cd $d && git checkout f70020509dd4800fe8aaf5ae0c51f29b3ce58e39
RUN apt-get install --quiet --yes re2c
RUN cd /usr/local/src/zephir && ./install
RUN ln -s /usr/local/src/zephir/bin/zephir /usr/local/bin
RUN apt-get install --quiet --yes libpcre3-dev php5-dev sudo

ENV ZEPHIRDIR /usr/local/src/zephir
