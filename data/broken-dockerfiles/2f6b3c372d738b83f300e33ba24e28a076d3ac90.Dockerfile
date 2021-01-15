FROM crystallang/crystal:latest

MAINTAINER Andrés García <andres@loopa.io>

RUN apt-get update && \
    apt-get install crystal && \
    mkdir -p /usr/src/app

WORKDIR /usr/src/app

ADD src src
ADD shard.yml shard.yml

RUN shards install && \
    crystal build --release src/app.cr

EXPOSE 80
