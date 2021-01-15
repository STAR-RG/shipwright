#
# Dockerfile for cpuminer
# usage: docker run creack/cpuminer --url xxxx --user xxxx --pass xxxx
# ex: docker run creack/cpuminer --url stratum+tcp://ltc.pool.com:80 --user creack.worker1 --pass abcdef
#
#

FROM		ubuntu:17.10
MAINTAINER	Guillaume J. Charmes <guillaume@charmes.net>

RUN		apt-get update -qq

RUN		apt-get install -qqy automake
RUN		apt-get install -qqy libcurl4-openssl-dev
RUN		apt-get install -qqy git
RUN		apt-get install -qqy build-essential
RUN		apt-get install -qqy libssl-dev
RUN		apt-get install -qqy libgmp-dev
RUN   apt-get install -qqy libjansson-dev

RUN		git clone https://github.com/fireworm71/veriumMiner

RUN		cd veriumMiner && ./build.sh

WORKDIR		/veriumMiner
ENTRYPOINT	["./cpuminer"]
