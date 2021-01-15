# Multi-stage Dockerfile for `stencila/nixta`

# Build the Nixta binary
# Note that the `nixta` binary produced will include native modules
# e.g. `better-sqlite3.node` for the platform it is built on (so it needs
# to be a Linux builder to run on Linux-based Docker image)
# You can test this stage alone by building and running like this:
#   docker build . --target builder --tag stencila/nixta:builder
#   docker run --rm -it -p 3000:3000 stencila/nixta:builder ./build/nixta serve

FROM node:10 AS builder
WORKDIR /nixta
# Copy package.json and install packages, instead of doing it whenever the src changes
COPY package.json .
RUN npm install
# Prefetch required Node.js binaries, instead of doing it whenever the src changes
RUN touch dummy.js && npx pkg dummy.js --target=node10 --out-path=build && rm -rf build && rm dummy.js
# Copy everything and build!
COPY envs envs/
COPY src src/
COPY tsconfig.json .
RUN npm run build

# Main image with Nix installed and Nixta copied into it
#
# This is based on https://github.com/NixOS/docker/blob/master/Dockerfile
# but modified to run on Ubuntu.

# TODO cleanup and condense into fewer RUN directives

FROM ubuntu:18.04

ENV NIX_VERSION=2.2.1 NIX_SHA=e229e28f250cad684c278c9007b07a24eb4ead239280c237ed2245871eca79e0
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y wget ca-certificates xz-utils \
 && wget https://nixos.org/releases/nix/nix-${NIX_VERSION}/nix-${NIX_VERSION}-x86_64-linux.tar.bz2 \
 && echo "${NIX_SHA} nix-${NIX_VERSION}-x86_64-linux.tar.bz2" | sha256sum -c \
 && tar xjf nix-${NIX_VERSION}-x86_64-linux.tar.bz2 \
 && rm nix-${NIX_VERSION}-x86_64-linux.tar.bz2

# Create a non-root user
RUN groupadd --gid 30000 nixbld \
  && for i in $(seq 1 30); do useradd --uid $((30000 + i)) --groups nixbld nixbld$i ; done
RUN useradd --uid 1001 --create-home --groups nixbld nixta
RUN install --mode 755 --owner nixta --directory /nix

ENV USER root

RUN mkdir -m 0755 /etc/nix \
 && echo 'sandbox = false' > /etc/nix/nix.conf

#USER nixta

RUN USER=root sh nix-*-x86_64-linux/install \
 && rm -rf nix-${NIX_VERSION}-x86_64-linux
#RUN /nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-old \
# && /nix/var/nix/profiles/default/bin/nix-store --optimise \
# && /nix/var/nix/profiles/default/bin/nix-store --verify --check-contents

# Install Docker (only the client is used in this image, the daemon runs elsewhere)
# HT to https://stackoverflow.com/a/43594065
ENV DOCKER_VERSION=18.09.1
RUN wget https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz \
 && tar xzvf docker-${DOCKER_VERSION}.tgz --strip 1 -C /usr/local/bin docker/docker \
 && rm docker-${DOCKER_VERSION}.tgz

COPY --from=builder /nixta/bin/nixta /home/nixta

WORKDIR /home/nixta

# Prepend application directory and Nix profile to PATH
ENV PATH=/home/nixta:/root/.nix-profile/bin:/root/.nix-profile/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Check that Nixta is installed properly and do bootstapping of native Node modules
RUN nixta --help

# Check that Nix is installed properly
RUN nix-env --version

RUN nix-channel --add https://nixos.org/channels/nixos-18.09 \
 && nix-channel --update \
 && nixta update nixos-18.09

CMD nixta serve
