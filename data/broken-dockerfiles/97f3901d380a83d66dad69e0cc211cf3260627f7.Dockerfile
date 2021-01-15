## docker-coreos-build-kernel-module

### A docker image for building CoreOS kernel modules

FROM ubuntu:14.04
MAINTAINER Ian Blenke <ian@blenke.com>

RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive gcc-4.7 g++-4.7 wget git make dpkg-dev

RUN update-alternatives --remove gcc /usr/bin/gcc-4.8 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.7 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.8 && \
    update-alternatives --config gcc

RUN mkdir -p /usr/src/kernels

WORKDIR /usr/src/kernels

RUN git clone https://github.com/coreos/linux.git

ENV COREOS_VERSION $(uname -r | sed -e 's/+$//')

WORKDIR /usr/src/kernels/linux

RUN git checkout remotes/origin/coreos/v$COREOS_VERSION

RUN zcat /proc/config.gz > .config

RUN make modules_prepare

RUN sed -i -e "s/$COREOS_VERSION/$(uname -r)/" include/generated/utsrelease.h

WORKDIR /usr/src

# From here you would pull down your kernel source and build it relative to the linux kernel source tree prepared in /usr/src/kernels/linux

CMD /bin/bash -li
