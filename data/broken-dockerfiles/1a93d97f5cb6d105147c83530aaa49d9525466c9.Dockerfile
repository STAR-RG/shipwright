FROM ruby:2.2.0
RUN apt-get update -yqq
RUN apt-get install -y build-essential
RUN apt-get install -y nodejs
RUN apt-get install -y npm
RUN apt-get install -y libpq-dev
RUN mkdir /mwdc
WORKDIR /mwdc
ADD Gemfile /mwdc/Gemfile
ADD Gemfile.lock /mwdc/Gemfile.lock
RUN bundle install
ADD . /mwdc
