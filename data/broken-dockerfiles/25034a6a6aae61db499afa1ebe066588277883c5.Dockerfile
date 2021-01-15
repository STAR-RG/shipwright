FROM ruby:2.4.1-slim

RUN set -ex \
    && apt-get update \
    && apt-get install -qq -y --no-install-recommends build-essential libpq-dev git curl \
    && (curl -sL https://deb.nodesource.com/setup_7.x | bash -) \
    && (curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -) \
    && (echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list) \
    && apt-get update \
    && apt-get install -qq -y nodejs yarn

ENV INSTALL_PATH /zen

RUN mkdir -p $INSTALL_PATH{,/client}

WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile.lock ./
RUN bundle install --binstubs

COPY package.json yarn.lock ./
COPY client/package.json client/yarn.lock ./client/

RUN yarn install

COPY . ./

RUN bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname SECRET_KEY_BASE=dummytoken assets:precompile

VOLUME ["$INSTALL_PATH/public"]

CMD puma -C config/puma.rb
