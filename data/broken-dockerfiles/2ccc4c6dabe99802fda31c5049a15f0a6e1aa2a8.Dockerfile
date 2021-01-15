FROM ubuntu:vivid
MAINTAINER caktux

ENV DEBIAN_FRONTEND noninteractive

# Usual update / upgrade
RUN apt-get update
RUN apt-get upgrade -q -y
RUN apt-get dist-upgrade -q -y

# Install useful tools
RUN apt-get install -q -y sudo wget vim git

# Install requirements
RUN apt-get install -q -y graphviz-dev libfreetype6-dev pkg-config python python-dev

# Install pip
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py

# Install docker-machine, docker-compose and docker client
RUN wget -O /usr/bin/docker-machine https://github.com/docker/machine/releases/download/v0.2.0/docker-machine_linux-amd64
RUN chmod +x /usr/bin/docker-machine
RUN wget -O /usr/bin/docker-compose https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m`
RUN chmod +x /usr/bin/docker-compose
RUN wget -O /usr/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-latest
RUN chmod +x /usr/bin/docker

# We add requirements.txt first to prevent unnecessary local rebuilds
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Add existing machines, which can be saved using `docker cp <container>:/root/.docker/machine/machines ./`
# ADD machines /root/.docker/machine/machines

# Install system-testing
ADD . system-testing
WORKDIR system-testing
RUN pip install -e .

VOLUME ["/root/.boto"]
