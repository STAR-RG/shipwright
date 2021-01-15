FROM ruby:2.5

ARG uid

RUN apt-get update && apt-get install -y postgresql-client

RUN useradd -M -u $uid mtools
USER mtools
