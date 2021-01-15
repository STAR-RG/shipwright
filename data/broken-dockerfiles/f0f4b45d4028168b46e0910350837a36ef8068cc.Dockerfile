FROM ruby:2.2.4

RUN \
  apt-get update -qq && \
  apt-get install -y build-essential zlib1g-dev libmysqlclient-dev libssl-dev && \
  apt-get clean

WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

RUN bundle install -j4

ADD . /app/

ENV PATH /app/bin:$PATH
VOLUME /app/app /app/config /app/db /app/lib /app/locale /app/public /app/test

CMD rm -f tmp/pids/server.pid && bundle exec rails server -b 0.0.0.0
