# VERSION 0.1
# DOCKER-VERSION  0.7.3
# AUTHOR:         Sam Alba <sam@docker.com>, Dr Nic Williams <drnicwilliams@gmail.com>
# DESCRIPTION:    Image with docker-registry project and dependecies
# TO_BUILD:       docker build -rm -t registry .
# TO_RUN:         docker run -p 5000:5000 -v cache:/registry registry

FROM ubuntu:13.04

RUN apt-get update; \
    apt-get install -y git-core build-essential python-dev \
    libevent1-dev python-openssl liblzma-dev wget; \
    rm /var/lib/apt/lists/*_*
RUN cd /tmp; wget http://python-distribute.org/distribute_setup.py
RUN cd /tmp; python distribute_setup.py; easy_install pip; \
    rm distribute_setup.py
ADD docker-registry /docker-registry
ADD docker-registry/config/boto.cfg /etc/boto.cfg

RUN cd /docker-registry && pip install -r requirements.txt

EXPOSE 5000
VOLUME ["/registry"]

ENV dev_version 1
ADD config-local-standalone.yml /docker-registry/config/config.yml

WORKDIR /docker-registry
CMD ./setup-configs.sh && ./run.sh

