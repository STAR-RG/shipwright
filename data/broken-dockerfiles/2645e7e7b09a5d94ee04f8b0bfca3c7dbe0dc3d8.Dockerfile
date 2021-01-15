FROM ruby:2.3.1

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    nodejs \
    mysql-client

RUN mkdir /SIGS-MES

WORKDIR /SIGS-MES

COPY SIGS/Gemfile /SIGS-MES/Gemfile
COPY SIGS/Gemfile.lock /SIGS-MES/Gemfile.lock
RUN bundle install

COPY . /SIGS-MES

EXPOSE  3000
CMD ["rails", "server", "-b", "0.0.0.0"]
