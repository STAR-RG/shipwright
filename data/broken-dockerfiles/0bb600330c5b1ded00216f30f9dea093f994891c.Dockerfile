FROM ubuntu:latest
MAINTAINER Adam Baxter
RUN apt-get update
RUN apt-get install --no-install-recommends -y make g++ unzip parted kpartx qemu-utils git wget python-minimal bc patch rsync

RUN git clone --depth=1 git://github.com/buildroot/buildroot
RUN git clone --depth=1 git://github.com/voltagex/serial-vm-buildroot

RUN cd serial-vm-buildroot && make serial_defconfig && make
