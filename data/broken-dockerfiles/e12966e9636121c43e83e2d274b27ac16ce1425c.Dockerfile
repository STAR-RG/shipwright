FROM debian:9

ARG OS_NAME=linux
ENV OS_NAME=$OS_NAME

# install build tools and dependencies

RUN apt-get update && \
    apt-get install -y  \
    build-essential=12.3 \
    curl=7.52.1-5+deb9u9 \
    unzip=6.0-21+deb9u2 \
    git=1:2.11.0-3+deb9u4 \
    python3=3.5.3-1 \
    python3-pip=9.0.1-2+deb9u1 \
    python-protobuf=3.0.0-9 \
    wget=1.18-5+deb9u3 \
    libusb-1.0.0-dev=2:1.0.21-1 \
    cmake=3.7.2-1 \
    udev=232-25+deb9u12 \
    sudo=1.8.19p1-2.1

RUN python3 -m pip uninstall pip && \
    apt-get install python3-pip --reinstall

# download toolchain

ENV TOOLCHAIN_SHORTVER=6-2017q2
ENV TOOLCHAIN_LONGVER=gcc-arm-none-eabi-6-2017-q2-update
ENV TOOLCHAIN_URL=https://developer.arm.com/-/media/Files/downloads/gnu-rm/$TOOLCHAIN_SHORTVER/$TOOLCHAIN_LONGVER-$OS_NAME.tar.bz2

# extract toolchain

RUN cd /opt && \
    wget $TOOLCHAIN_URL && \
    tar xfj $TOOLCHAIN_LONGVER-$OS_NAME.tar.bz2

# download protobuf

ENV PROTOBUF_VERSION=3.6.1
RUN wget "https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip"

ENV STLINK_VERSION=1.5.0
RUN wget "https://github.com/texane/stlink/archive/${STLINK_VERSION}.zip"

# setup toolchain

ENV PATH=/opt/$TOOLCHAIN_LONGVER/bin:$PATH

ENV PYTHON=python3
ENV PIP=pip3
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# use zipfile module to extract files world-readable
RUN $PYTHON -m zipfile -e "protoc-${PROTOBUF_VERSION}-linux-x86_64.zip" /usr/local && \
    chmod 755 /usr/local/bin/protoc
RUN $PYTHON -m zipfile -e "1.5.0.zip" /tmp && \
    cd /tmp/stlink-1.5.0 && \
    make release && \
    cd build/Release && \
    make install && \
    ldconfig

RUN useradd -m user
USER user

RUN $PYTHON -m pip install --user "protobuf==3.6.1" ecdsa
