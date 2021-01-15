FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04@sha256:238cc73e12c381e1469815f7ee149028a2ee3d557b68ff9b12d907c2d3ea3c04

MAINTAINER Shiva Manne <manneshiva@gmail.com>

# Compile Tensorflow from source for better performance/speed
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/docker/Dockerfile.devel-gpu
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential=12.1ubuntu2 \
        curl=7.47.0-1ubuntu2.5 \
        git=1:2.7.4-0ubuntu1.3 \
        libcurl3-dev \
        libfreetype6-dev=2.6.1-0.1ubuntu2.3 \
        libpng12-dev=1.2.54-1ubuntu1 \
        libzmq3-dev=4.1.4-7 \
        pkg-config=0.29.1-0ubuntu1 \
        python-dev=2.7.11-1 \
        rsync=3.1.1-3ubuntu1 \
        software-properties-common=0.96.20.7 \
        unzip=6.0-20ubuntu1 \
        zip=3.0-11 \
        zlib1g-dev=1:1.2.8.dfsg-2ubuntu4.1 \
        openjdk-8-jdk=8u151-b12-0ubuntu0.16.04.2 \
        openjdk-8-jre-headless=8u151-b12-0ubuntu0.16.04.2 \
        vim=2:7.4.1689-3ubuntu1.2 \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fSsL -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip --no-cache-dir install \
        ipykernel==4.6.1 \
        jupyter==1.0.0 \
        matplotlib==2.0.2 \
        numpy==1.13.1 \
        scipy==0.19.1 \
        && \
    python -m ipykernel.kernelspec

# Set up Bazel.

# Running bazel inside a `docker build` command causes trouble, cf:
#   https://github.com/bazelbuild/bazel/issues/134
# The easiest solution is to set up a bazelrc file forcing --batch.
RUN echo "startup --batch" >>/etc/bazel.bazelrc
# Similarly, we need to workaround sandboxing issues:
#   https://github.com/bazelbuild/bazel/issues/418
RUN echo "build --spawn_strategy=standalone --genrule_strategy=standalone" \
    >>/etc/bazel.bazelrc
# Install the most recent bazel release.
ENV BAZEL_VERSION 0.5.4
WORKDIR /
RUN mkdir /bazel && \
    cd /bazel && \
    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -o /bazel/LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE && \
    chmod +x bazel-*.sh && \
    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    cd / && \
    rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh

# Download and build TensorFlow.

RUN git clone https://github.com/tensorflow/tensorflow.git && \
    cd tensorflow && \
    git checkout r1.4
WORKDIR /tensorflow

# Configure the build for our CUDA configuration.
ENV CI_BUILD_PYTHON python
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
ENV TF_NEED_CUDA 1
ENV TF_CUDA_COMPUTE_CAPABILITIES=3.0,3.5,5.2,6.0,6.1
ENV TF_CUDA_VERSION=8.0
ENV TF_CUDNN_VERSION=6

RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
RUN LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${LD_LIBRARY_PATH} \
    tensorflow/tools/ci_build/builds/configured GPU \
    bazel build -c opt --config=cuda --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" \
        --copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-mfpmath=both --copt=-msse4.1 --copt=-msse4.2 \
        tensorflow/tools/pip_package:build_pip_package
RUN rm /usr/local/cuda/lib64/stubs/libcuda.so.1
RUN bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip && \
    pip --no-cache-dir install --upgrade /tmp/pip/tensorflow-*.whl && \
    rm -rf /tmp/pip && \
    rm -rf /root/.cache
# Clean up pip wheel and Bazel cache when done.

WORKDIR /root

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

WORKDIR /

# Install python packages
RUN pip --no-cache-dir install \
        gensim==2.1.0 \
        memory_profiler==0.47 \
        psutil==5.2.2 \
        snowballstemmer==1.2.1 \
        PyStemmer==1.3.0 \
        keras==2.1.3 \
        tqdm==4.19.5 \
        gputil==1.2.3

# set python hash seed
ENV PYTHONHASHSEED 12345

COPY ./benchmark-GPU-platforms /benchmark-GPU-platforms

WORKDIR /
CMD ["/bin/bash"]
