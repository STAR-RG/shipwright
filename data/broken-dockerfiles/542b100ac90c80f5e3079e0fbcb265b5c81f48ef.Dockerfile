FROM ubuntu:14.04
MAINTAINER Nathan Hopkins <natehop@gmail.com>
ENV RBX_VERSION 2.5.8

RUN apt-get -y --force-yes install lsb-release && \
  echo deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) main universe > /etc/apt/sources.list.d/universe.list && \
  apt-get -q update

# dependencies
RUN apt-get -y --force-yes install \
  curl \
  wget \
  git \
  gcc \
  g++ \
  make \
  flex \
  bison \
  ruby1.9.1-dev \
  llvm-dev \
  zlib1g-dev \
  libyaml-dev \
  libssl-dev \
  libgdbm-dev \
  libreadline-dev \
  libncurses5-dev

RUN echo "install: --no-document\nupdate: --no-document" > /etc/gemrc

# language
RUN locale-gen en_US.UTF-8 && \
  update-locale LANG=en_US.UTF-8 && \
  echo "export LC_ALL=en_US.UTF-8" >> /etc/environment
ENV LC_ALL en_US.UTF-8

# download & install
RUN gem install bundler
WORKDIR /usr/local/src
RUN wget --quiet http://releases.rubini.us/rubinius-${RBX_VERSION}.tar.bz2 && \
  tar jxf rubinius-${RBX_VERSION}.tar.bz2
WORKDIR /usr/local/src/rubinius-${RBX_VERSION}
RUN curl -fsSL curl.haxx.se/ca/cacert.pem -o ./library/rubygems/ssl_certs/cacert.pem
RUN bundle
RUN ./configure --prefix=/usr/local/rbx --libc=/usr/lib/x86_64-linux-gnu/libc
RUN rake install
RUN /usr/local/rbx/bin/gem install --no-document bundler

# cleanup
RUN rm -rf /usr/local/src/rubinius-${RBX_VERSION}.tar.bz2 && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/* && \
  rm -rf /var/tmp/*
RUN apt-get clean

WORKDIR /root
ENV HOME /root
ENV PATH /usr/local/rbx/bin:/usr/local/rbx/gems/bin:$PATH
