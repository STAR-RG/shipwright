FROM ubuntu:xenial
RUN apt-get update \
    && apt-get install -y vim git wget \
    && apt-get install -y cmake build-essential autoconf curl libtool libboost-all-dev unzip \ 
    && apt-get install -y python-pip
RUN pip install --upgrade pip
RUN git clone https://github.com/robertnishihara/ray.git
RUN pip install numpy
RUN cd /ray \
    && git checkout storeport

COPY start_ray.py /ray/scripts/start_ray.py

RUN cd /ray \ 
    && ./build.sh \
    && cd python \
    && pip install -e .  
