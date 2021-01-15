FROM ruby:2.2.4
MAINTAINER Eric McNiece <emcniece@gmail.com>

ENV CHECKOUT_ID=5f8692ef3ee19df32b7f20b169c7eca7a00a9477

RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential \
    # for postgres
    libpq-dev \
    # for nokogiri
    libxml2-dev libxslt1-dev \
    # for capybara-webkit
    libqt4-webkit libqt4-dev xvfb \
    python python-dev python-pip python-virtualenv \
    nodejs \
    # cleanup
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p boarding && cd boarding \
 && git clone https://github.com/fastlane/boarding.git . \
 && git checkout $CHECKOUT_ID \
 && gem install bundler \
 && bundle install

WORKDIR /boarding
CMD bundle exec puma -C config/puma.rb