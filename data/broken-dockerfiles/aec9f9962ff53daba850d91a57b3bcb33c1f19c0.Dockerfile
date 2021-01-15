FROM gcr.io/tensorflow/tensorflow:1.3.0-devel-gpu-py3

RUN apt-get update && \
        apt-get install -y \
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libjasper-dev \
        libavformat-dev \
        libpq-dev \
        python3-pip \
        python-dev \
        libopencv-dev

RUN apt-get install python3-tk

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

WORKDIR /src