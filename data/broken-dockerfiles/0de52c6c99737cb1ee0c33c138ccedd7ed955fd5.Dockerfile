# This file was generated using a Jinja2 template.
# Please make your changes in `Dockerfile.j2` and then `make` the individual Dockerfile's.

# Using multistage build:
# 	https://docs.docker.com/develop/develop-images/multistage-build/
# 	https://whitfin.io/speeding-up-rust-docker-builds/
####################### VAULT BUILD IMAGE  #######################

#  This hash is extracted from the docker web-vault builds and it's prefered over a simple tag because it's immutable.
#  It can be viewed in multiple ways:
#  - From the https://hub.docker.com/repository/docker/bitwardenrs/web-vault/tags page, click the tag name and the digest should be there.
#  - From the console, with the following commands:
#      docker pull bitwardenrs/web-vault:v2.13.2b
#      docker image inspect --format "{{.RepoDigests}}" bitwardenrs/web-vault:v2.13.2b
#
#  - To do the opposite, and get the tag from the hash, you can do:
#      docker image inspect --format "{{.RepoTags}}" bitwardenrs/web-vault@sha256:f32c555a2bc3ee6bc0718319b1e8057c10ef889cf7231f0ff217af98486da554
FROM bitwardenrs/web-vault@sha256:f32c555a2bc3ee6bc0718319b1e8057c10ef889cf7231f0ff217af98486da554 as vault

########################## BUILD IMAGE  ##########################
# We need to use the Rust build image, because
# we need the Rust compiler and Cargo tooling
FROM rust:1.40 as build

# set mysql backend
ARG DB=mysql

# Build time options to avoid dpkg warnings and help with reproducible builds.
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 TZ=UTC TERM=xterm-256color

# Don't download rust docs
RUN rustup set profile minimal

# Install required build libs for arm64 architecture.
RUN sed 's/^deb/deb-src/' /etc/apt/sources.list > \
        /etc/apt/sources.list.d/deb-src.list \
    && dpkg --add-architecture arm64 \
    && apt-get update \
    && apt-get install -y \
        --no-install-recommends \
        libssl-dev:arm64 \
        libc6-dev:arm64

RUN apt-get update \
    && apt-get install -y \
        --no-install-recommends \
        gcc-aarch64-linux-gnu \
    && mkdir -p ~/.cargo \
    && echo '[target.aarch64-unknown-linux-gnu]' >> ~/.cargo/config \
    && echo 'linker = "aarch64-linux-gnu-gcc"' >> ~/.cargo/config

ENV CARGO_HOME "/root/.cargo"
ENV USER "root"

# Install MySQL package
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    libmariadb-dev:arm64 \
    && rm -rf /var/lib/apt/lists/*

# Creates a dummy project used to grab dependencies
RUN USER=root cargo new --bin /app
WORKDIR /app

# Copies over *only* your manifests and build files
COPY ./Cargo.* ./
COPY ./rust-toolchain ./rust-toolchain
COPY ./build.rs ./build.rs

ENV CC_aarch64_unknown_linux_gnu="/usr/bin/aarch64-linux-gnu-gcc"
ENV CROSS_COMPILE="1"
ENV OPENSSL_INCLUDE_DIR="/usr/include/aarch64-linux-gnu"
ENV OPENSSL_LIB_DIR="/usr/lib/aarch64-linux-gnu"
RUN rustup target add aarch64-unknown-linux-gnu

# Builds your dependencies and removes the
# dummy project, except the target folder
# This folder contains the compiled dependencies
RUN cargo build --features ${DB} --release
RUN find . -not -path "./target*" -delete

# Copies the complete project
# To avoid copying unneeded files, use .dockerignore
COPY . .

# Make sure that we actually build the project
RUN touch src/main.rs

# Builds again, this time it'll just be
# your actual source files being built
RUN cargo build --features ${DB} --release --target=aarch64-unknown-linux-gnu

######################## RUNTIME IMAGE  ########################
# Create a new stage with a minimal image
# because we already have a binary built
FROM balenalib/aarch64-debian:buster

ENV ROCKET_ENV "staging"
ENV ROCKET_PORT=80
ENV ROCKET_WORKERS=10

RUN [ "cross-build-start" ]

# Install needed libraries
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    openssl \
    ca-certificates \
    curl \
    libmariadbclient-dev \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /data

RUN [ "cross-build-end" ]

VOLUME /data
EXPOSE 80
EXPOSE 3012

# Copies the files from the context (Rocket.toml file and web-vault)
# and the binary from the "build" stage to the current stage
COPY Rocket.toml .
COPY --from=vault /web-vault ./web-vault
COPY --from=build /app/target/aarch64-unknown-linux-gnu/release/bitwarden_rs .

COPY docker/healthcheck.sh /healthcheck.sh

HEALTHCHECK --interval=60s --timeout=10s CMD ["/healthcheck.sh"]

# Configures the startup!
WORKDIR /
CMD ["/bitwarden_rs"]
