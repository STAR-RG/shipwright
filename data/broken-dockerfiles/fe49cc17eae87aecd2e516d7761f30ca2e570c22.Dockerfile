FROM ruby:2.3.1

RUN apt-get update && apt-get install -y mysql-client nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

ARG APP_HOME

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile $APP_HOME/
ADD Gemfile.lock $APP_HOME/

RUN bundle install
