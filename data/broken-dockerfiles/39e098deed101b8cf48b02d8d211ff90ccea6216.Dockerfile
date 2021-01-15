FROM ubuntu:14.04

MAINTAINER carlad "https://github.com/carlad"

# Install packages for building ruby
RUN apt-get update
RUN apt-get install -y --force-yes build-essential wget git
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev
RUN apt-get clean

RUN wget -P /root/src http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.gz
RUN cd /root/src; tar xvf ruby-2.2.2.tar.gz
RUN cd /root/src/ruby-2.2.2; ./configure; make install

RUN gem update --system
RUN gem install bundler

RUN git clone https://github.com/travis-ci/docker-sinatra /root/sinatra
RUN cd /root/sinatra; bundle install

EXPOSE 4567
