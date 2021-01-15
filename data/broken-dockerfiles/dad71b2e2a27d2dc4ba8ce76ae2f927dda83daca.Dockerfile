FROM docker:latest

MAINTAINER Benjamin Schwarze <benjamin.schwarze@mailboxd.de>

RUN apk add --no-cache \
    gcc \
    git \
    libffi-dev \
    make \
    musl-dev \
    openssl-dev \
    perl \
    py-pip \
    python \
    python-dev \
    sshpass \
    wget

RUN pip install --upgrade pip && \
    pip install goodplay
