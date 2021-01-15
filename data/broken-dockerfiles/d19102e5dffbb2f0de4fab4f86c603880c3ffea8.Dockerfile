# -*- sh -*-
FROM ruby:2.2

RUN gem install -n /usr/bin bundler
RUN gem install -n /usr/bin rake

RUN apt-get update && apt-get install -y tinycdb && apt-get clean

ADD bundle_config /usr/local/bundle/config

WORKDIR /app

