FROM ubuntu:trusty
MAINTAINER Evan Cordell <cordell.evan@gmail.com>

## Prepare
RUN apt-get clean all && apt-get update && apt-get upgrade -y

# Build Tools
RUN apt-get update && \
    apt-get install -y build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev pkg-config software-properties-common && \
    apt-add-repository ppa:ubuntu-lxc/lxd-stable && \
    apt-get install -y make wget tar git curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Install libsodium
ENV LIBSODIUM_VERSION 1.0.8

RUN wget https://github.com/jedisct1/libsodium/releases/download/$LIBSODIUM_VERSION/libsodium-$LIBSODIUM_VERSION.tar.gz && \
  tar xzvf libsodium-$LIBSODIUM_VERSION.tar.gz && \
  cd libsodium-$LIBSODIUM_VERSION && \
  ./configure && \
  make && make check && sudo make install && \
  cd .. && rm -rf libsodium-$LIBSODIUM_VERSION && \
  sudo ldconfig

# Install Python
RUN apt-get update && \
    apt-get install -y python3-pip python3-dev python3-software-properties && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Ruby
RUN cd /tmp && \
  wget -q http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.2.tar.gz && \
  tar xzf ruby-2.1.2.tar.gz && \
  cd ruby-2.1.2 && \
  ./configure --enable-shared --prefix=/usr && \
  make && \
  make install && \
  cd .. && \
  rm -rf ruby-2.1.2* && \
  cd ..

# Install Node
ENV NODE_PREFIX /usr/local
ENV NODE_PATH $NODE_PREFIX/lib/node_modules
ENV NODE_VERSION 0.11.14
ENV NPM_VERSION 2.1.6

RUN wget -q "http://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C $NODE_PREFIX --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" \
  && npm install -g npm@"$NPM_VERSION" \
  && npm cache clear

# Install Go
RUN apt-get update && \
    apt-get install -y golang bzr && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir /usr/go
ENV GOROOT /usr/lib/go
ENV GOPATH /usr/go

# Install PHP
RUN apt-get update && \
    apt-get install -y php5 php5-dev php-pear && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Rust
ENV RUST_VERSION 1.12.0
RUN apt-get update && \
    curl -sO https://static.rust-lang.org/dist/rust-$RUST_VERSION-x86_64-unknown-linux-gnu.tar.gz && \
    tar -xvzf rust-$RUST_VERSION-x86_64-unknown-linux-gnu.tar.gz && \
    ./rust-$RUST_VERSION-x86_64-unknown-linux-gnu/install.sh && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* rust-$RUST_VERSION-x86_64-unknown-linux-gnu{,.tar.gz}

# Install libmacaroons
RUN wget -O - http://ubuntu.hyperdex.org/hyperdex.gpg.key | apt-key add - && \
    echo "deb [arch=amd64] http://ubuntu.hyperdex.org trusty main" >> /etc/apt/sources.list.d/hyperdex.list && \
    apt-get update && \
    apt-get install -y python-macaroons && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /usr/src

# Install pymacaroons
RUN pip3 install pymacaroons pytest pytest-html

# Install ruby-macaroons
RUN gem install macaroons -v 0.6.1

# Install macaroons.js
RUN npm install -g macaroons.js

# Install go-macaroons
RUN go get launchpad.net/gorun && \
    go get gopkg.in/macaroon.v1 && \
    go get gopkg.in/macaroon-bakery.v1/bakery

# Install php-macaroons
ADD implementations/php-macaroons /usr/src/implementations/php-macaroons
RUN pecl install libsodium-1.0.6 && \
    echo "extension=libsodium.so" >> /etc/php5/cli/php.ini && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/bin/composer && \
    cd implementations/php-macaroons && \
    composer install

# Install rust-macaroons
RUN mkdir /usr/rust && cd /usr/rust && \
    git clone https://github.com/cryptosphere/rust-macaroons.git /usr/rust/rust-macaroons && \
    cd rust-macaroons && \
    cargo build

# Add source
ADD . /usr/src
