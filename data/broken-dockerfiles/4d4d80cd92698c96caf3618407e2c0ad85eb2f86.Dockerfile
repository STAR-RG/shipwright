############################################################
# Dockerfile to build kifu, a minimal web application based on Pyramid, Bootstrap, Redis, Rabbit MQ, Supervisor
# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Michael Hanna

# Update the repository sources list
# And set up compilation environment
RUN apt-get update && apt-get install -y \
    gcc \
    git \
    python \
    python-dev \
    libffi-dev \
    build-essential \
    curl \
    libbz2-dev \
    libexpat-dev \
    nginx \
    redis \
    rabbitmq \

RUN mkdir kifu_install
RUN cd kifu_install

# get and install virtualenv
RUN curl -O https://pypi.python.org/packages/source/v/virtualenv/virtualenv-13.1.1.tar.gz#md5=22d36ae617d6e962d8a486f58b5ebd2a
RUN tar zxvf virtualenv-13.1.1.tar.gz
RUN cd virtualenv-13.1.1
RUN python setup.py install

RUN cd ..

RUN curl -O http://pyyaml.org/download/pyyaml/PyYAML-3.11.tar.gz
RUN tar zxvf PyYAML-3.11.tar.gz
RUN cd PyYAML-3.11.tar.gz/
RUN python setup.py install


RUN cd ..

RUN git clone https://github.com/wcdolphin/python-bcrypt.git
RUN cd python-bcrypt
RUN python setup.py install

# RUN cd ..

