FROM alpine:3.7

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    NPM_CONFIG_PRODUCTION="false" \
    RUNTIME_PACKAGES="bash ruby ruby-irb ruby-json ruby-rake ruby-bigdecimal ruby-io-console ruby-dev nodejs yarn libxml2-dev libxslt-dev mariadb-client-libs tzdata py-pip" \
    DEV_PACKAGES="build-base mariadb-dev"

RUN apk add --update --no-cache $RUNTIME_PACKAGES && \
    pip install --no-cache-dir awscli && \
    mkdir /app

WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN apk add --update --virtual build-dependencies --no-cache $DEV_PACKAGES && \
    gem install bundler --no-document && \
    bundle config build.nokogiri --use-system-libraries && \
    bundle install --without development test heroku && \
    apk del build-dependencies

COPY package.json /app/package.json
COPY yarn.lock /app/yarn.lock

RUN yarn install --network-concurrency 1 && \
    yarn cache clean

COPY . /app

RUN yarn run build && \
    bundle exec rake assets:precompile DATABASE_URL=nulldb://localhost SECRET_KEY_BASE=secret_key_base

EXPOSE 3000
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
