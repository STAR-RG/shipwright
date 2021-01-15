FROM r-base:3.6.1

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libblas-dev \
    liblapack-dev \
    gfortran \
    python3.7 \
    python3-pip \
    python3-setuptools \
    python3-dev \
    cmake \
    libcurl4-openssl-dev \
    libgsl0-dev \
    libeigen3-dev \
    libssl-dev \
    libcairo2-dev \
    libxt-dev \
    libxml2-dev \
    libgtk2.0-dev \
    libcairo2-dev \
    xvfb  \
    xauth \
    xfonts-base \
    libz-dev \
    libhdf5-dev

WORKDIR /app

COPY . .

RUN pip3 install -r requirements.txt
RUN Rscript packages.R
RUN pip3 install .

ENTRYPOINT ["/bin/bash"]
