FROM phusion/passenger-nodejs:0.9.15
# FROM node:0.10-onbuild
MAINTAINER Colin Curtin <colin.t.curtin@gmail.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Install stuff here
# WORKDIR /tmp
# ADD package.json package.json
# RUN npm install

RUN mkdir -p /home/app
ADD . /home/app/valor
WORKDIR /home/app/valor
# OSX make sad :(
RUN mv node_modules/jdataview node_modules/jDataView
# RUN rm -rf node_modules
# RUN mv /tmp/node_modules /home/app/valor

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /home/app/valor
ENTRYPOINT make all
