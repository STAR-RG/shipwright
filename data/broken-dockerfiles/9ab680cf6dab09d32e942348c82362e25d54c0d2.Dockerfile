############################################################
# Dockerfile to build seneca-level-store test container
# Based on Node image
############################################################

FROM node

MAINTAINER Mircea Alexandru <mircea.alexandru@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

#############################################
##  Clone store
#############################################

WORKDIR /opt/app
COPY level-store.js level-store.js
COPY test test
COPY .eslintrc .eslintrc
COPY package.json package.json

#############################################
# Install dependencies
#############################################
RUN npm install

ENTRYPOINT npm run test