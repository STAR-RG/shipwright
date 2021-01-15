FROM ruby:2.6-alpine
MAINTAINER Jurgens du Toit <jurgens@datatools.io>

EXPOSE 9292
# Add your certificates to the project and uncomment the following lines to enable SSL
# COPY privkey.pem /usr/src/app
# COPY fullchain.pem /usr/src/app
# EXPOSE 9293

WORKDIR /usr/src/app
RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev \
  openssh \
  openssl \
  openssl-dev \
  sqlite-dev \
  && rm -rf /var/cache/apk/* \
  && mkdir /root/.ssh \
  && mkdir /usr/src/app/config \
  && touch /var/log/cron.log \
  && ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts \
  && gem install bundler

COPY Rakefile /usr/src/app/
COPY Gemfile.deploy /usr/src/app/Gemfile
COPY Gemfile.deploy.lock /usr/src/app/Gemfile.lock

RUN bundle install \
  && bundle exec rake ditty:prep

ADD views /usr/src/app/views
ADD public /usr/src/app/public
COPY config.ru /usr/src/app/
COPY application.rb /usr/src/app/
COPY config/settings.yml /usr/src/app/config/
COPY config/puma.rb /usr/src/app/config/
COPY startup.sh /
RUN chmod 755 /startup.sh

VOLUME /usr/src/app/config

ENV APP_ROOT="/usr/src/app"
ENV RACK_ENV="production"

ENTRYPOINT ["/startup.sh"]
