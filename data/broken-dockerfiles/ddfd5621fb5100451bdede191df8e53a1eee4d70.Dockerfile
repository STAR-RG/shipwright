FROM evild/alpine-nodejs:6.3.0
MAINTAINER DOMINIQUE HAAS <contact@dominique-haas.fr>

ARG MAILTRAIN_VERSION=1.20.0

RUN set -ex && apk add --no-cache curl \
  && cd /tmp \
  && curl -fSL https://github.com/andris9/mailtrain/archive/v${MAILTRAIN_VERSION}.tar.gz -o mailtrain.tar.gz \
  && tar xzf mailtrain.tar.gz \
  && mkdir /app \
  && mv mailtrain-${MAILTRAIN_VERSION}/*  /app

WORKDIR /app
RUN npm install --production

ADD root /
