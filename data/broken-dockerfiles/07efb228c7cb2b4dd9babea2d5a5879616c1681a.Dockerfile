FROM ubuntu:14.04
MAINTAINER Festi Team

RUN apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:chris-lea/node.js

RUN apt-get upgrade -y
RUN apt-get update -y
RUN apt-get autoremove -y

RUN apt-get install -y python-pip python-dev nodejs redis-server git libmysqlclient-dev

RUN npm install -g bower

ADD festi /festi
RUN pip install -r /festi/reqs/prod.txt

WORKDIR /festi/festi
RUN bower install --allow-root

ENV C_FORCE_ROOT true
ENV PYTHONIOENCODING utf-8
ENV DJANGO_SETTINGS_MODULE festi.settings.prod

ADD docker_run_server.sh /
EXPOSE 8000

WORKDIR /festi/

CMD /docker_run_server.sh
