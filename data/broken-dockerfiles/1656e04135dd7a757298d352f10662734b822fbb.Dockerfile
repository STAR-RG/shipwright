FROM ubuntu:16.04

LABEL maintainer Andrew Beard <bearda@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y --no-install-recommends git software-properties-common wget python-pip python-setuptools less nano vim
RUN pip install --upgrade pip

# Add the official Bro package repository and install Bro
RUN wget -q http://download.opensuse.org/repositories/network:bro/xUbuntu_16.04/Release.key -O Release.key && \
    apt-key add Release.key && \
    rm -f Release.key && \
    apt-add-repository -y 'deb http://download.opensuse.org/repositories/network:/bro/xUbuntu_16.04/ /' && \
    apt-get update && \
    apt-get install -y --no-install-recommends bro

ENV BRO_HOME /opt/bro
ENV PATH $BRO_HOME/bin/:$PATH

# Install the Bro package manager
RUN pip install bro-pkg
RUN bro-pkg autoconfig && \
    echo "@load packages" >> /opt/bro/share/bro/site/local.bro
