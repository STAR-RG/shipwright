# Copied from https://hexdocs.pm/distillery/guides/working_with_docker.html#the-dockerfile
# Switch alpine once this issue is fixed: https://github.com/rust-lang/rustup.rs/issues/640#issuecomment-274550200
FROM elixir:1.7.4 AS builder
ARG APP_NAME=blacksmith
ARG APP_VERSION=0.1.0
ARG MIX_ENV=prod
ARG PHOENIX_SUBDIR=.
ENV APP_NAME=${APP_NAME} \
    APP_VERSION=${APP_VERSION} \
    MIX_ENV=${MIX_ENV}

WORKDIR /opt/app

RUN apt-get update && apt-get install -y  \
    autoconf \
    build-essential \
    curl \
    git \
    libgmp-dev \
    libtool \
    rebar &&\
  mix local.rebar --force && \
  mix local.hex --force

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly
ENV PATH=/root/.cargo/bin:$PATH
COPY . .
RUN mix do deps.get, deps.compile, compile

RUN mkdir -p /opt/built
RUN ls rel/hooks
RUN mix release --verbose --env=prod
RUN cp _build/${MIX_ENV}/rel/${APP_NAME}/releases/${APP_VERSION}/${APP_NAME}.tar.gz /opt/built
RUN cd /opt/built && \
  tar -xzf ${APP_NAME}.tar.gz && \
  rm ${APP_NAME}.tar.gz && \
  cp /opt/app/deps/libsecp256k1/priv/libsecp256k1_nif.so lib/libsecp256k1-0.1.10/priv

RUN find / -name transaction_processor
FROM debian:stretch
ARG APP_NAME

ENV REPLACE_OS_VARS=true \
    APP_NAME=${APP_NAME}

WORKDIR /opt/app

COPY --from=builder /opt/built .
RUN apt-get update && apt-get install -y \
  bash \
  libgmp-dev \
  libssl-dev \
  postgresql-client \
  openssl

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
CMD trap 'exit' INT;echo $MIX_ENV; echo $WEB3_URL; /opt/app/bin/${APP_NAME} foreground
