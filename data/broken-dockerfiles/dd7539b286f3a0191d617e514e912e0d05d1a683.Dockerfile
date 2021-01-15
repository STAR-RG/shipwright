FROM nvidia/cuda:8.0-cudnn7-devel-ubuntu16.04

SHELL ["/bin/bash", "-c"]

RUN rm -rf /var/lib/apt/lists/* \
           /etc/apt/sources.list.d/cuda.list \
           /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        wget \
        git \
        vim \
        nano \
        less \
        tmux \
        htop \
        screen \
        curl \
        mc \
        openssh-server \
        openssh-client && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3 \
        python3-dev && \
    wget -O ~/get-pip.py \
        https://bootstrap.pypa.io/get-pip.py && \
    python3 ~/get-pip.py && \
    pip3 --no-cache-dir install \
        setuptools \
        numpy==1.14.1 \
        scipy==1.0.0 \
        matplotlib==2.1.2 \
        pandas==0.22.0 \
        scikit-learn==0.19.1 \
        opencv-python==3.2.0.8 \
        Cython==0.27.3 \
        jupyterlab==0.32.1 \
        pyyaml==3.12 \
        scikit-image>=0.9.3 \
        h5py>=2.2.0 \
        networkx>=1.8.1 \
        nose>=1.3.0 \
        pytest && \
    cd /tmp && \
    git clone https://github.com/pytorch/pytorch.git && \
    cd pytorch && \
    git checkout v0.4.1 && \
    git submodule update --init --recursive && \
    python3 setup.py install && \
    pip --no-cache-dir install \
        torchvision==0.2.1 \
        tensorboardX==1.2 && \
    printf "export LC_ALL=C.UTF-8\n" >> /etc/environment && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/*

COPY ./source /source
