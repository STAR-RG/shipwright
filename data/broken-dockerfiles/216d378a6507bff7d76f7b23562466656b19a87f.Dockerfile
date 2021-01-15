FROM ubuntu:trusty

MAINTAINER Kinn Coelho Julião <kinncj@php.net>

ADD ./phpng /opt/phpng/
RUN chmod 755 /opt/phpng/*
WORKDIR /opt/phpng/

RUN echo 'PHPNG Docker'

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -yq wget \
 m4

RUN wget http://launchpadlibrarian.net/140087283/libbison-dev_2.7.1.dfsg-1_amd64.deb
RUN wget http://launchpadlibrarian.net/140087282/bison_2.7.1.dfsg-1_amd64.deb

RUN dpkg -i libbison-dev_2.7.1.dfsg-1_amd64.deb
RUN dpkg -i bison_2.7.1.dfsg-1_amd64.deb

RUN wget http://repos.zend.com/zend.key -O- 2> /dev/null | apt-key add -

RUN echo "deb [arch=amd64] http://repos.zend.com/zend-server/early-access/phpng/ trusty zend" > /etc/apt/sources.list.d/phpng.list

RUN apt-get update
RUN apt-get install -yq git \
 curl \
 apache2 \
 php5 \
 libapache2-mod-php5


RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h

EXPOSE 80
