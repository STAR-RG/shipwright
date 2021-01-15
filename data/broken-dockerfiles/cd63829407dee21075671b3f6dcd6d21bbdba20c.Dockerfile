FROM debian:8.8

MAINTAINER hecke <hecke@naberius.de>

# unrar is non-free
RUN "echo" "deb http://http.us.debian.org/debian wheezy non-free" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
	autoconf \
	automake \
	bison \
	bzip2 \
	flex \
	g++ \
	gawk \
	gcc \
	git \
	gperf \
	libexpat-dev \
	libtool \
	libtool-bin \
	make \
	ncurses-dev \
	nano \
	python \
	python-dev \
	python-serial \
	sed \
	texinfo \
	unrar \
	unzip \
	wget \
	help2man

RUN useradd -ms /bin/bash espbuilder && usermod -a -G dialout espbuilder

USER espbuilder

RUN cd /home/espbuilder && git clone --recursive https://github.com/pfalcon/esp-open-sdk.git

RUN cd /home/espbuilder/esp-open-sdk && make STANDALONE=n

RUN (cd /home/espbuilder/ && git clone https://github.com/esp8266/source-code-examples.git)

RUN (cd /home/espbuilder/ && git clone https://github.com/tommie/esptool-ck.git && cd esptool-ck && make )

ENV PATH /home/espbuilder/esp-open-sdk/xtensa-lx106-elf/bin:/home/espbuilder/esp-open-sdk/esptool/:$PATH
ENV XTENSA_TOOLS_ROOT /home/espbuilder/esp-open-sdk/xtensa-lx106-elf/bin
ENV SDK_BASE /home/espbuilder/esp-open-sdk/ESP8266_NONOS_SDK_V2.0.0_16_08_10/
ENV FW_TOOL /home/espbuilder/esptool-ck/esptool

CMD (cd /home/espbuilder/ && /bin/bash)
