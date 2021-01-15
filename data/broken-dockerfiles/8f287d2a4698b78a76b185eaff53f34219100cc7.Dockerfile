FROM ruby:2.3.1-alpine

WORKDIR /enerbot
COPY . /enerbot
RUN apk --update add --virtual build-dependencies ruby-dev build-base && \
    gem install bundler --no-ri --no-rdoc && \
    bundle install --without development test && \
    apk del build-dependencies

CMD [ "ruby", "client.rb" ]