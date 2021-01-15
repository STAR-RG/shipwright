# Set the base image
FROM ubuntu:16.10

# Dockerfile author / maintainer 
MAINTAINER Joel Quiles <quilesbaker@gmail.com> 

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get clean

RUN apt-get install -y curl git apt-utils vim

RUN curl -O https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
RUN mv lein /usr/bin
RUN chmod +x /usr/bin/lein

RUN adduser docked
RUN usermod -aG sudo docked

USER docked

RUN lein -v

ADD . /code
WORKDIR /code

RUN lein deps