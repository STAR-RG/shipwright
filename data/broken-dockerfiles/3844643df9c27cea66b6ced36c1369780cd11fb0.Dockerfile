
# Pull base image
FROM resin/rpi-raspbian:jessie
MAINTAINER Dieter Reuter <dieter@hypriot.com>

# Install dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libc6-dev \
    gcc \
    btrfs-tools \
    curl \
    libsqlite3-dev \
    libdevmapper-dev \
    fakeroot \
    git-core \
    python-pip \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Install Go (using a pre-compiled version)
ENV GO_VERSION 1.4.3
RUN curl -sSL https://github.com/hypriot/golang-armbuilds/releases/download/v${GO_VERSION}/go${GO_VERSION}.linux-armv7.tar.gz | tar -xz -C /usr/local
ENV PATH /usr/local/go/bin:$PATH

# Install AWS CLI
RUN pip install awscli

# Clone Docker
RUN \
    mkdir -p /src && \
    cd /src && \
    git clone https://github.com/docker/docker.git

# Debian package template
ADD pkg-debian /pkg-debian

# Builder script
COPY builder.sh /
