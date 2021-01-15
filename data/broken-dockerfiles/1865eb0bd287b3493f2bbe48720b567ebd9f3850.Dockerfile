From nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

ARG PROJECT_DIR=/chainer-skin-lesion-detector

WORKDIR $PROJECT_DIR
COPY requirements.txt $PROJECT_DIR

RUN apt-get update && apt-get install -y \
    software-properties-common && \
    add-apt-repository ppa:jonathonf/python-3.6 -y && \
    apt-get -y update && \
    apt-get install -y \
    git \
    python3.6 \
    python3.6-dev \
    python3-pip \
    python3-tk \
    libsm6 \
    libxext6 && \
    ln -fns /usr/bin/python3.6 /usr/bin/python && \
    ln -fns /usr/bin/python3.6 /usr/bin/python3 && \
    ln -fns /usr/bin/pip3 /usr/bin/pip

RUN pip install -r requirements.txt
