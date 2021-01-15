FROM ubuntu:18.04

LABEL MAINTAINER="Casey Primozic <me@ameo.link>"

RUN apt-get update && apt-get install -y apt-transport-https build-essential cmake git python curl libssl-dev pkg-config

# Install `wasm-opt`
RUN git clone https://github.com/WebAssembly/binaryen.git /tmp/binaryen
WORKDIR /tmp/binaryen
RUN cmake . && make && make install

# Install Rust via rustup
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup target add wasm32-unknown-unknown

# Install `wasm-bindgen-cli` and `wasm-bindgen`
RUN cargo install wasm-bindgen-cli
RUN cargo install wasm-gc

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get -y install yarn

RUN mkdir /app
WORKDIR /app
