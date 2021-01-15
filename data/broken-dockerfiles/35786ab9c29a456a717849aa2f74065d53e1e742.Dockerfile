FROM debian:buster
ENV LIBSODIUM_VERSION 1.0.16

RUN apt-get update && apt-get install -y curl make gcc g++ && \
    mkdir -p /tmpbuild/libsodium && \
    cd /tmpbuild/libsodium && \
    curl -L https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VERSION.tar.gz -o libsodium-$LIBSODIUM_VERSION.tar.gz && \
    tar xfvz libsodium-$LIBSODIUM_VERSION.tar.gz && \
    cd /tmpbuild/libsodium/libsodium-$LIBSODIUM_VERSION/ && \
    ./configure && \
    make && make check && \
    make install

RUN apt-get update && apt-get install -y maven openjdk-8-jdk git && \
    git clone https://github.com/nbaars/paseto4j && \
    cd paseto4j; mvn clean install

