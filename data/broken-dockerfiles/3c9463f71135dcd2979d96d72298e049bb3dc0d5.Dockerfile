FROM ubuntu:latest
MAINTAINER Eivind Lindbråten <eivindml@icloud.com>

RUN apt-get update -q && apt-get install -y \
  software-properties-common

RUN add-apt-repository ppa:jonathonf/texlive

RUN apt-get update -q && apt-get install -y \
    texlive-full \
    && rm -rf /var/lib/apt/lists/*

RUN tlmgr install \
  moderncv \
  alegreya

RUN mkdir /tmp
WORKDIR /tmp
