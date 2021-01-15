FROM ubuntu:14.04

MAINTAINER Bertrand Bordage, bordage.bertrand@gmail.com


# Disables recommended packages installed as dependencies.
RUN echo "APT::Install-Recommends \"false\";\n\
APT::AutoRemove::RecommendsImportant \"false\";\n\
APT::AutoRemove::SuggestsImportant \"false\";" > /etc/apt/apt.conf.d/99_norecommends

ADD http://packages.elasticsearch.org/GPG-KEY-elasticsearch /
RUN apt-key add GPG-KEY-elasticsearch
RUN rm GPG-KEY-elasticsearch
RUN echo "deb http://packages.elasticsearch.org/elasticsearch/0.90/debian stable main" >> /etc/apt/sources.list
RUN apt-get update

RUN apt-mark auto `apt-mark showmanual`
RUN apt-mark manual ubuntu-minimal
RUN apt-get -y autoremove
RUN apt-get -y upgrade


RUN apt-get -y install git mercurial ca-certificates
RUN git clone https://github.com/dezede/dezede
WORKDIR /dezede/
RUN git submodule init
RUN git submodule update


RUN apt-get -y install postgresql postgresql-server-dev-9.3 redis-server
RUN apt-get -y install elasticsearch openjdk-7-jre
RUN apt-get -y install python2.7 python-pip python-dev
RUN apt-get -y install libxml2 libxml2-dev libxslt1-dev  # lxml dependencies
RUN apt-get -y install npm  # For LESS & elasticsearch

# Installs LESS CSS
RUN npm install -g less@1.7.0
RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN apt-get -y build-dep pillow
RUN pip install -r requirements.txt


RUN apt-get clean


# Enables Redis UNIX socket
RUN echo "unixsocket /var/run/redis/redis.sock\n\
unixsocketperm 777" >> /etc/redis/redis.conf


USER postgres
RUN service postgresql start && psql -c "CREATE USER dezede CREATEDB;" && psql -c "CREATE DATABASE dezede OWNER dezede;"
RUN sed -i 's/# Database administrative login by Unix domain socket/&\nlocal dezede,test_dezede dezede trust/' /etc/postgresql/9.3/main/pg_hba.conf


USER root
EXPOSE 8000

CMD service postgresql start && service redis-server start && python manage.py runserver 0.0.0.0:8000
