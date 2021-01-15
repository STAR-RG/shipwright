FROM ubuntu:14.04
MAINTAINER Benjamin Henrion <zoobab@gmail.com>

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y -q
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q --force-yes build-essential subversion git-core libncurses5-dev zlib1g-dev gawk flex quilt libssl-dev xsltproc libxml-parser-perl mercurial bzr ecj cvs unzip wget

RUN useradd -d /home/openwrt -m -s /bin/bash openwrt
RUN echo "openwrt ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/openwrt
RUN chmod 0440 /etc/sudoers.d/openwrt

USER openwrt

WORKDIR /home/openwrt
RUN git clone --quiet https://github.com/mirrors/openwrt.git
WORKDIR /home/openwrt/openwrt
# checking out version 48724 (svn) == 4eba46dc3a80529146329a5f28629429d6fb3cd5 (git)
RUN git checkout 4eba46dc3a80529146329a5f28629429d6fb3cd5
RUN echo "CONFIG_TARGET_ar71xx=y" > .config
RUN make defconfig
RUN make prereq
RUN make -j`nproc` tools/install
RUN make -j`nproc` toolchain/install
RUN echo "src-git zmq https://github.com/zoobab/openwrt-zmq-packages.git" >> feeds.conf.default
RUN ./scripts/feeds update zmq
RUN ./scripts/feeds install -p zmq
RUN ./scripts/feeds update -a
RUN ./scripts/feeds install -a
RUN make -j`nproc`

RUN echo "CONFIG_PACKAGE_glard=y" >> .config
RUN make oldconfig
RUN make -j`nproc`
