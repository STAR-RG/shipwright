# -*- sh -*-
FROM ruby:2.2

RUN gem install -n /usr/bin bundler
RUN gem install -n /usr/bin rake

ADD bundle_config /usr/local/bundle/config

WORKDIR /app

