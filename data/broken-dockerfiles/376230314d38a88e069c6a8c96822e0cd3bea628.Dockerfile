FROM node:7.10.0-alpine

MAINTAINER Laurin Quast <laurinquast@googlemail.com>

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN mkdir -p /usr/src/app
RUN chown -R 1001:root /usr/src/app
RUN mkdir /.npm
RUN chown -R 1001:root /.npm
WORKDIR /usr/src/app

USER 1001
COPY package.json /usr/src/app
RUN npm install
COPY . /usr/src/app
RUN npm run build


EXPOSE 8080
CMD [ "sh", "-c", "cd /usr/src/app ; npm run migrate:db ; npm start" ]
