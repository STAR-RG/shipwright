FROM ubuntu:xenial

ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive
ENV SHELL /bin/bash


RUN apt-get update && apt-get install -y locales sudo
RUN locale-gen en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

ENV EPSILON_DIR /epsilon
ENV EPSILON_ISOLATE /usr/local/bin/isolate

# Install add-apt-repository
RUN sed -i 's/archive.ubuntu.com/is.archive.ubuntu.com/' /etc/apt/sources.list
RUN apt-get update -qq && apt-get install -y software-properties-common

# Install all dependencies
RUN mkdir /epsilon_setup
WORKDIR /epsilon_setup
RUN mkdir -p scripts/ubuntu
ADD ./scripts/ubuntu /epsilon_setup/scripts/ubuntu
RUN ./scripts/ubuntu/setup-all.sh

ADD ./requirements.txt /epsilon_setup/
RUN pip3 install -r requirements.txt

# Build isolate
RUN mkdir -p judge/isolate
ADD ./judge/isolate /epsilon_setup/judge/isolate
WORKDIR /epsilon_setup/judge/isolate
RUN make && ./fix_mod.sh
RUN cp isolate /usr/local/bin/isolate
RUN chown root /usr/local/bin/isolate && chmod u+s /usr/local/bin/isolate
WORKDIR /epsilon_setup

RUN mkdir -p docker
ADD ./docker /epsilon_setup/docker

# Create a mountpoint for the app
RUN mkdir /epsilon

WORKDIR /epsilon

ENTRYPOINT ["/epsilon_setup/docker/entrypoint.sh"]
