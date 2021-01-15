ARG UBUNTU_VERSION
ARG CUDA_VERSION
ARG CUDNN_VERSION

FROM nvidia/cuda:${CUDA_VERSION}-cudnn${CUDNN_VERSION}-devel-ubuntu${UBUNTU_VERSION}

ARG UBUNTU_VERSION
ARG CUDA_VERSION
ARG CUDNN_VERSION

ENV DEBIAN_FRONTEND noninteractive

# Install common dependencies (so that this step can be cached separately)
ARG EC2
ADD ./common/install_base.sh install_base.sh
RUN bash ./install_base.sh && rm install_base.sh

# Install user
ADD ./common/install_user.sh install_user.sh
RUN bash ./install_user.sh && rm install_user.sh

# Install katex
ARG KATEX
ADD ./common/install_katex.sh install_katex.sh
RUN bash ./install_katex.sh && rm install_katex.sh

# Install conda
ENV PATH /opt/conda/bin:$PATH
ARG ANACONDA_PYTHON_VERSION
ADD ./common/install_conda.sh install_conda.sh
RUN bash ./install_conda.sh && rm install_conda.sh

# Install gcc
ARG GCC_VERSION
ADD ./common/install_gcc.sh install_gcc.sh
RUN bash ./install_gcc.sh && rm install_gcc.sh

# Install non-standard Python versions (via Travis binaries)
ARG TRAVIS_PYTHON_VERSION
ENV PATH /opt/python/$TRAVIS_PYTHON_VERSION/bin:$PATH
ADD ./common/install_travis_python.sh install_travis_python.sh
RUN bash ./install_travis_python.sh && rm install_travis_python.sh

# (optional) Install protobuf for ONNX
ARG PROTOBUF
ADD ./common/install_protobuf.sh install_protobuf.sh
RUN if [ -n "${PROTOBUF}" ]; then bash ./install_protobuf.sh; fi
RUN rm install_protobuf.sh
ENV INSTALLED_PROTOBUF ${PROTOBUF}

# (optional) Install database packages like LMDB and LevelDB
ARG DB
ADD ./common/install_db.sh install_db.sh
RUN if [ -n "${DB}" ]; then bash ./install_db.sh; fi
RUN rm install_db.sh
ENV INSTALLED_DB ${DB}

# (optional) Install vision packages like OpenCV and ffmpeg
ARG VISION
ADD ./common/install_vision.sh install_vision.sh
RUN if [ -n "${VISION}" ]; then bash ./install_vision.sh; fi
RUN rm install_vision.sh
ENV INSTALLED_VISION ${VISION}

# Install ccache/sccache (do this last, so we get priority in PATH)
ADD ./common/install_cache.sh install_cache.sh
ENV PATH /opt/cache/bin:$PATH
RUN bash ./install_cache.sh && rm install_cache.sh
ENV CUDA_NVCC_EXECUTABLE=/opt/cache/lib/nvcc

# Add jni.h for java host build
ADD ./common/install_jni.sh install_jni.sh
ADD ./java/jni.h jni.h
RUN bash ./install_jni.sh && rm install_jni.sh

# Include BUILD_ENVIRONMENT environment variable in image
ARG BUILD_ENVIRONMENT
ENV BUILD_ENVIRONMENT ${BUILD_ENVIRONMENT}

# AWS specific CUDA build guidance
ENV TORCH_CUDA_ARCH_LIST Maxwell
ENV TORCH_NVCC_FLAGS "-Xfatbin -compress-all"

USER jenkins
CMD ["bash"]
