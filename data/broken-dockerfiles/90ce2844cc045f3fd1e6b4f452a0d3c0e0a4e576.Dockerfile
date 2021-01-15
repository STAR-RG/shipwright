FROM ruby:2.5
MAINTAINER HowToHireMe Team <opensource@howtohireme.ru>

RUN apt-get -y update
RUN apt-get -y install nodejs netcat

WORKDIR /app
COPY ./ .
ENV RAILS_ENV production

RUN gem install foreman
RUN bundle install --deployment --without development test
RUN cp config/database.yml.sample config/database.yml

RUN rake assets:precompile

EXPOSE 5000

CMD rm -f /app/tmp/pids/server.pid && rake db:migrate && foreman start


