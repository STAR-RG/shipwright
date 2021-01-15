FROM ubuntu
MAINTAINER James Gregory <james@jagregory.com>

# install wget
RUN echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe" > /etc/apt/sources.list
RUN apt-get update -y && apt-get install -y wget

# download kindlegen and install it to /usr/bin
RUN wget http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz -O /tmp/kindlegen_linux_2.6_i386_v2_9.tar.gz
RUN tar -xzf /tmp/kindlegen_linux_2.6_i386_v2_9.tar.gz -C /tmp
RUN mv /tmp/kindlegen /usr/bin
RUN rm -r /tmp/*

RUN mkdir -p /source
WORKDIR /source

ENTRYPOINT ["kindlegen"]
