#
# Dockerfile for cpuminer
# usage: docker run hmage/cpuminer-opt --url xxxx --user xxxx --pass xxxx
# ex: docker run hmage/cpuminer-opt -a lyra2 -o stratum+tcp://lyra2re.eu.nicehash.com:3342 -O 1HMageKbRBu12FkkFbMEcskAtH59TVrS2G.${HOSTNAME//-/}:x
#

FROM		debian:jessie
MAINTAINER	Eugene Bujak <hmage@hmage.net>

RUN		echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/zz-local-tame
RUN		apt-get update && apt-get upgrade -y && apt-get install -y git ca-certificates build-essential autoconf automake libssl-dev libcurl4-openssl-dev libjansson-dev libgmp-dev
RUN		git clone https://github.com/hmage/cpuminer-opt

WORKDIR		/cpuminer-opt

RUN		autoreconf -f -i -v && CFLAGS="-O3 -maes -mssse3 -mtune=intel -DUSE_ASM" CXXFLAGS="$CFLAGS -std=gnu++11" ./configure --with-curl && make -j8

ENTRYPOINT	["./cpuminer"]
