FROM ruby:2.2-onbuild
MAINTAINER Gabriel McArthur <gabriel.mcarthur@gmail.com>

# Pre-requisites
RUN echo "deb http://deb-multimedia.org jessie main non-free" > /etc/apt/sources.list.d/non-free.list
RUN apt-get update
RUN apt-get install -y --force-yes deb-multimedia-keyring
RUN apt-get install -y --force-yes ffmpeg

# Configure the user
RUN apt-get install -y zsh rlwrap vim-common vim-scripts vim-nox
RUN useradd USERNAME -u UID -s SHELL --no-create-home
VOLUME ["HOME"]

# Cleanup
USER root
RUN apt-get clean
