FROM ruby:2.2
RUN apt-get update -qq && apt-get install -y build-essential \
            libpq-dev curl postgresql-client imagemagick

RUN apt-get install locales
RUN echo 'ru_RU.UTF-8 UTF-8' >> /etc/locale.gen
RUN locale-gen ru_RU.UTF-8
RUN dpkg-reconfigure -fnoninteractive locales
ENV LC_ALL=ru_RU.utf8
ENV LANGUAGE=ru_RU.utf8
RUN update-locale LC_ALL="ru_RU.utf8" LANG="ru_RU.utf8" LANGUAGE="ru_RU"


RUN mkdir /myapp
ADD . /myapp
WORKDIR /myapp

RUN gem install bundler

RUN bundle install --jobs 3
# RUN bundle install --path=.bundle --standalone --jobs 0
