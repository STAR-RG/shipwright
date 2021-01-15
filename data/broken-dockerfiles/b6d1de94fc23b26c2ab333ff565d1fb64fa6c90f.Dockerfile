FROM ubuntu:16.04

WORKDIR /root

# Pick up some TF dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        pkg-config \
        rsync \
        software-properties-common \
        unzip \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install miniconda
RUN curl -LO http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh \
      && bash Miniconda-latest-Linux-x86_64.sh -p /miniconda -b \
      && rm Miniconda-latest-Linux-x86_64.sh
ENV PATH /miniconda/bin:$PATH

# Create a conda environment
ENV CONDA_ENV_NAME iris-predictor
COPY environment.yml  ./environment.yml
RUN conda env create -f environment.yml -n $CONDA_ENV_NAME
ENV PATH /miniconda/envs/${CONDA_ENV_NAME}/bin:$PATH

# cleanup tarballs and downloaded package files
RUN conda clean -tp -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# gRPC
EXPOSE 50052
# REST
EXPOSE 5000

# Environment variables
ENV MAX_WORKERS 1
ENV PORT 50052

COPY . /root/
CMD python grpc_server.py --max_workers ${MAX_WORKERS} --port ${PORT}
