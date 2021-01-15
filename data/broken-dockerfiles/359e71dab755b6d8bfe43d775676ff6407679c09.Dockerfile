# This file describes how to build Haraka into a runnable linux container with all dependencies installed
# To build:
# 1.) Install docker (http://docker.io)
# 2.) Clone haraka-http-forward repo if you haven't already: git clone https://github.com/jplock/haraka-http-forward.git
# 3.) Modify config/host_list with the domain(s) that you'd like to receive mail to
# 4.) Build: cd haraka-http-forward && docker build .
# 5.) Run:
# docker run -d <imageid>
# redis-cli -p <redisport>
#
# VERSION           0.2
# DOCKER-VERSION    0.6.1

FROM ubuntu
MAINTAINER Justin Plock <jplock@gmail.com>

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get -y -q install redis-server supervisor python-software-properties python g++ make git
RUN add-apt-repository ppa:chris-lea/node.js
RUN apt-get -y -q update
RUN apt-get -y -q install nodejs

RUN npm install -g Haraka
RUN mkdir -p /var/log/supervisor
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN haraka -i /usr/local/haraka
ADD ./config/data.http_forward.ini /usr/local/haraka/config/data.http_forward.ini
ADD ./config/plugins /usr/local/haraka/config/plugins
ADD ./config/host_list /usr/local/haraka/config/host_list
ADD ./docs/plugins/data.http_forward.md /usr/local/haraka/docs/plugins/data.http_forward.md
ADD ./plugins/data.http_forward.js /usr/local/haraka/plugins/data.http_forward.js
ADD ./package.json /usr/local/haraka/package.json
RUN cd /usr/local/haraka && npm install

# Haraka SMTP
EXPOSE 25
# Redis
EXPOSE 6379

CMD ["supervisord", "-n"]
