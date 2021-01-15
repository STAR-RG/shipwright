# Dockerfile
FROM quay.io/aptible/ruby:2.3

RUN apt-get update && apt-get -y install build-essential

# System prerequisites
RUN apt-get update && apt-get -y install libpq-dev

# Add Gemfile before rest of repo, for Docker caching purposes
# See http://ilikestuffblog.com/2014/01/06/
ADD Gemfile /lib/
ADD Gemfile.lock /lib/
WORKDIR /lib
RUN bundle install

ADD . /lib

ENV PORT 9292
EXPOSE 9292
