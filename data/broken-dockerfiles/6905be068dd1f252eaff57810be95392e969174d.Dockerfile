FROM ubuntu-debootstrap:14.04

RUN apt-get update && apt-get install -y --no-install-recommends \
  automake \
  bison \
  build-essential \
  bzip2 \
  ca-certificates \
  clang \
  cpio \
  curl \
  debhelper \
  file \
  g++-multilib \
  gcc-multilib \
  genisoimage \
  git \
  gobject-introspection \
  gzip \
  intltool \
  libgirepository1.0-dev \
  libgsf-1-dev \
  libssl-dev \
  libtool \
  libxml2-dev \
  llvm-dev \
  make \
  mingw-w64 \
  patch \
  rpm \
  sed \
  uuid-dev \
  valac \
  wget \
  xz-utils

# install ruby
RUN mkdir -p /opt/ruby-2.2.2/ && \
  curl -s https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/cedar-14/ruby-2.2.2.tgz | tar xzC /opt/ruby-2.2.2/
ENV PATH /opt/ruby-2.2.2/bin:$PATH

# install fpm to build packages (deb, rpm)
RUN gem install fpm --no-document

# install osx cross compiling tools
RUN cd /opt/ && \
  git clone https://github.com/tpoechtrager/osxcross.git
COPY MacOSX10.10.sdk.tar.bz2 /opt/osxcross/tarballs/
RUN echo "\n" | bash /opt/osxcross/build.sh
RUN rm /opt/osxcross/tarballs/*
ENV PATH /opt/osxcross/target/bin:$PATH
ENV SHELL /bin/bash

# install msitools
RUN cd /tmp && wget https://launchpad.net/ubuntu/+archive/primary/+files/gcab_0.6.orig.tar.xz && tar -xf gcab_0.6.orig.tar.xz && cd gcab-0.6 && ./configure && make && make install

RUN cd /tmp && wget https://launchpad.net/ubuntu/+archive/primary/+files/msitools_0.94.orig.tar.xz && tar -xf msitools_0.94.orig.tar.xz && cd msitools-0.94 && ./configure && make && make install

ONBUILD WORKDIR /home/mruby/code
ONBUILD ENV GEM_HOME /home/mruby/.gem/

ONBUILD ENV PATH $GEM_HOME/bin/:$PATH
ONBUILD ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/
