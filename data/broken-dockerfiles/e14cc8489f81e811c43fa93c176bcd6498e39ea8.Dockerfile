FROM ruby:2.4-alpine
MAINTAINER Zach Latta <zach@zachlatta.com>

RUN apk update && apk add --no-cache alpine-sdk git icu-dev

RUN mkdir /usr/src/app
WORKDIR /usr/src/app

ADD Gemfile /usr/src/app/Gemfile
ADD Gemfile.lock /usr/src/app/Gemfile.lock

ENV BUNDLE_GEMFILE=Gemfile \
  BUNDLE_JOBS=4 \
  BUNDLE_PATH=/bundle

RUN bundle install

ADD . /usr/src/app

CMD bin/start
