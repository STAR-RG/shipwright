FROM node:latest
MAINTAINER Hovig Ohannessian <hovigg@hotmail.com>
WORKDIR /opt/app
ADD . /opt/app
RUN  npm install
EXPOSE 3000
RUN ["node", "server"]
