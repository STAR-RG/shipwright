FROM nvidia/cuda:10.0-cudnn7-devel
ARG DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN set -x && apt-get update -y && apt-get install -y \
      cmake \
      libboost-all-dev \
      libglew-dev \
      libgoogle-glog-dev \
      libjsoncpp-dev \
      libopencv-dev \ 
      libopenni2-dev \
      unzip \
      wget \
      && rm -rf /var/lib/apt/lists/*

# Download TensorFlow C API
ARG TFAPI_URL=https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-gpu-linux-x86_64-1.15.0.tar.gz
RUN wget -qO - ${TFAPI_URL} | tar -C /usr/local -xvz

# Build DeepFactors
COPY . /DeepFactors
WORKDIR /DeepFactors

# build deps
RUN set -x && ./thirdparty/makedeps.sh --threads 2

# build slam
RUN set -x && \
    mkdir -p build && \
    cd build && \
    cmake \
      -DDF_BUILD_TOOLS=ON \
      -DDF_BUILD_TESTS=ON \
      -DDF_BUILD_DEMO=ON \
      -DDF_CUDA_ARCH="6.1" \
      .. && \
    make -j1

WORKDIR /DeepFactors
ENTRYPOINT ["/bin/bash"]
