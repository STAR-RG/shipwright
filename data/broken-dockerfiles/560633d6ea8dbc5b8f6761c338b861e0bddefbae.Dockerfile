FROM ubuntu:xenial

RUN apt-get update && apt-get -y install \
    curl unzip git build-essential autoconf automake dh-autoreconf libtool pkg-config g++

WORKDIR /opt/nginx-dev

COPY vendor.sh /
RUN /bin/bash -x /vendor.sh
