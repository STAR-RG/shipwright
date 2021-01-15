FROM ubuntu:disco
WORKDIR /build

ARG GHC_VERSION=8.6.5
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y install software-properties-common devscripts wget apt-utils

RUN add-apt-repository -s ppa:hvr/ghc && \
    apt-get update && \
    apt-get source ghc-$GHC_VERSION && \
    wget https://launchpad.net/~hvr/+archive/ubuntu/ghc/+files/alex-3.1.7_3.1.7-3~zesty_amd64.deb && \
    apt -y install ./alex*.deb && \
    rm ./alex*.deb && \
    apt-get -y build-dep ghc-$GHC_VERSION

COPY ./patches/ghc-$GHC_VERSION.patch /build/

WORKDIR /build/ghc-$GHC_VERSION-$GHC_VERSION
VOLUME /out
ENV GHC_VER $GHC_VERSION
ENV UID 0
ENV MAINTAINER "Nobody <nobody@example.com>"
CMD cat ../ghc-$GHC_VER.patch | sed -e "s/MAINTAINER/$MAINTAINER/g" | patch -u -p1 && \
    dpkg-buildpackage -b --no-sign && \
    cp ../*.deb /out/ && \
    chown $UID:$UID /out/*.deb