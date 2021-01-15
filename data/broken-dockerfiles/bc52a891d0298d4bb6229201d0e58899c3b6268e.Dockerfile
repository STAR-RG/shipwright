FROM tensorflow/tensorflow:latest-devel-gpu

MAINTAINER Gavin Gray <gavingray1729@gmail.com>

# go back to the tensorflow dir
WORKDIR /tensorflow

# Configure the build for our CUDA configuration.
ENV CUDA_TOOLKIT_PATH /usr/local/cuda
ENV CUDNN_INSTALL_PATH /usr/local/cuda
ENV TF_NEED_CUDA 1
ENV TF_CUDA_COMPUTE_CAPABILITIES=3.0

RUN ./configure && \
    bazel build -c opt --config=cuda tensorflow/tools/pip_package:build_pip_package && \
    bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip && \
    pip install --upgrade /tmp/pip/tensorflow-*.whl

WORKDIR /root

# Set up CUDA variables
ENV CUDA_PATH /usr/local/cuda

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

RUN ["/bin/bash"]
