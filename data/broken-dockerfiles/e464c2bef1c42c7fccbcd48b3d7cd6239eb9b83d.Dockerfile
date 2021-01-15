FROM nvidia/cuda:10.0-cudnn7-devel

ARG PYTHON_VERSION=3.7
RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         vim \
         ca-certificates \
         libjpeg-dev \
         libpng-dev &&\
     rm -rf /var/lib/apt/lists/*

RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \
     /opt/conda/bin/conda install -y python=$PYTHON_VERSION numpy pyyaml scipy ipython mkl mkl-include cython typing && \
     /opt/conda/bin/conda install -y pytorch torchvision cudatoolkit=10.0 -c pytorch && \
     /opt/conda/bin/conda install -y -c intel ipp-devel && \
     /opt/conda/bin/conda install -y -c conda-forge libjpeg-turbo && \
     /opt/conda/bin/conda clean -ya
ENV PATH /opt/conda/bin:$PATH

RUN pip install \
        adabound \
        cnn_finetune \
        logzero \
        munch \
        pretrainedmodels \
        protobuf \
        scikit-learn \
        tensorboardX &&\
    pip uninstall -y pillow &&\
    CC="cc -mavx2" pip install -U --force-reinstall pillow-simd

RUN git clone https://github.com/pytorch/accimage.git /accimage
COPY setup_conda.py /accimage
RUN cd /accimage && \
    python setup_conda.py install --user
