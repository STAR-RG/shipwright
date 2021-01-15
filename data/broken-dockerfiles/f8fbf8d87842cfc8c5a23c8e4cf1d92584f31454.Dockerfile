FROM ruby:2.4

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  curl \
  imagemagick \
  libpq-dev \
  nodejs \
  postgresql \
  redis-tools \
  vim \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN npm install -g yarn

RUN apt-get install locales
RUN echo 'ru_RU.UTF-8 UTF-8' >> /etc/locale.gen
RUN locale-gen ru_RU.UTF-8
RUN dpkg-reconfigure -fnoninteractive locales
ENV LC_ALL=ru_RU.utf8
ENV LANGUAGE=ru_RU.utf8
RUN update-locale LC_ALL="ru_RU.utf8" LANG="ru_RU.utf8" LANGUAGE="ru_RU"

ENV EDITOR=vim

ARG APP_DIR=/app

RUN mkdir -p $APP_DIR
WORKDIR $APP_DIR
