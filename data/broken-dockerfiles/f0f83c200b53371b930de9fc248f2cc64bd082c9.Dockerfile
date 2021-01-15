FROM ubuntu:14.04
MAINTAINER Jonathan Ostrander "jonathanost@gmail.com"

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# Required packages
RUN apt-get update
RUN apt-get -y install \
    build-essential \
    git \
    libhdf5-dev \
    software-properties-common \
    wget

# Torch and luarocks
RUN git clone https://github.com/torch/distro.git ~/torch --recursive && cd ~/torch && \
    bash install-deps && \
    ./install.sh -b

ENV PATH=/root/torch/install/bin:$PATH

RUN luarocks install torch
RUN luarocks install nn
RUN luarocks install optim
RUN luarocks install lua-cjson
RUN luarocks install https://raw.githubusercontent.com/benglard/htmlua/master/htmlua-scm-1.rockspec
RUN luarocks install https://raw.githubusercontent.com/benglard/waffle/master/waffle-scm-1.rockspec

RUN mkdir /opt/server
ADD . /opt/server

WORKDIR /opt/server/checkpoints
RUN wget http://from.robinsloan.com/rnn-writer/scifi-model.zip && unzip scifi-model.zip
