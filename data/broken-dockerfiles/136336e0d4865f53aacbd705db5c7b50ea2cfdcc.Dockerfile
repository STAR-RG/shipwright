# Compile PHP with static linked dependencies
# to create a single running binary

# Lambda is based on 2017.03
# * don't grab the latest revion of the amazonlinux image. 
FROM amazonlinux:2017.03

ARG PHP_VERSION

# Lambda is based on 2017.03
# * dont' grab the latest revisions of development packages.
RUN yum --releasever=2017.03 install \
    autoconf \
    automake \
    libtool \
    bison \
    re2c \
    libxml2-devel \
    openssl-devel \
    libpng-devel \
    libjpeg-devel \
    ssh \
    which \
    curl-devel -y

RUN curl -sL https://github.com/php/php-src/archive/$PHP_VERSION.tar.gz | tar -zxv

WORKDIR /php-src-$PHP_VERSION

RUN ./buildconf --force
ARG BUILD_ARGUMENTS

RUN ./configure $BUILD_ARGUMENTS

ARG JOBS
RUN make -j $JOBS

RUN ls /php-src-$PHP_VERSION/sapi/*
RUN yum install findutils openssh-clients -y

RUN find / -name 'ssh'
RUN ssh -v