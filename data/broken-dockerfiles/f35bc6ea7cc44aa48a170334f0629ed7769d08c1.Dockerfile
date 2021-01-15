FROM bitnami/minideb:jessie

RUN install_packages python curl ca-certificates \
        build-essential \
        curl \
        git \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python-dev \
        python-numpy \
        python-pip \
        software-properties-common \
        swig \
        zip \
	unzip \
        zlib1g-dev \
        libcurl3-dev

RUN pip install --upgrade pip

RUN pip install enum34 futures mock six && \
    pip install --pre 'protobuf>=3.0.0a3' && \
    pip install -i https://testpypi.python.org/simple --pre grpcio

RUN echo "deb http://httpredir.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/backports.list && install_packages -t jessie-backports openjdk-8-jdk-headless

# Running bazel inside a `docker build` command causes trouble, cf:
#   https://github.com/bazelbuild/bazel/issues/134
# The easiest solution is to set up a bazelrc file forcing --batch.
RUN echo "startup --batch" >>/root/.bazelrc
# Similarly, we need to workaround sandboxing issues:
#   https://github.com/bazelbuild/bazel/issues/418
RUN echo "build --spawn_strategy=standalone --genrule_strategy=standalone" \
    >>/root/.bazelrc
ENV BAZELRC /root/.bazelrc
# Install the most recent bazel release.
ENV BAZEL_VERSION 0.4.5
WORKDIR /

# Configure options for Bazel build
ENV PYTHON_BIN_PATH /usr/bin/python
ENV PYTHON_LIB_PATH /usr/local/lib/python2.7/dist-packages
ENV CC_OPT_FLAGS -march=native
ENV TF_NEED_JEMALLOC 1
ENV TF_NEED_GCP 0
ENV TF_NEED_VERBS 0
ENV TF_NEED_HDFS 0
ENV TF_ENABLE_XLA 0
ENV TF_NEED_OPENCL 0
ENV TF_NEED_CUDA 0

# Files to delete after tensorflow compilation
ENV FILES_TO_DELETE /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/host/ \
    		    /root/.cache/bazel/_bazel_root/install/ \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/external/org_tensorflow/tensorflow/core/ \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/external/org_tensorflow/tensorflow/c/ \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/external/org_tensorflow/tensorflow/cc/ \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/external/org_tensorflow/tensorflow/stream_executor/ \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/tensorflow_serving/batching \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/tensorflow_serving/servables \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/tensorflow_serving/core \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/tensorflow_serving/apis \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/tensorflow_serving/test_util \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/tensorflow_serving/config \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/tensorflow_serving/resources \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/tensorflow_serving/sources \
		    /root/.cache/bazel/_bazel_root/*/execroot/serving/bazel-out/local-opt/bin/tensorflow_serving/util \
		    /usr/local/lib/bazel \
		    /usr/local/bin/bazel \
		    /root/.cache/pip/ \
		    /serving/.git \
		    /serving/tf_models/syntaxnet

# Bazel installation, tensorflow compilation and cleaning up
RUN mkdir /bazel && \
    cd /bazel && \
    curl -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    curl -fSsL -o /bazel/LICENSE https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE && \
    chmod +x bazel-*.sh && \
    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    cd / && \
    rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    git clone --recurse-submodules https://github.com/tensorflow/serving && \
    cd serving/tensorflow && \
    ./configure && \
    cd .. && \
    bazel build --local_resources 4000,1.0,1.0 --compilation_mode opt --strip=always tensorflow_serving/... && \
    rm -rf $FILES_TO_DELETE

WORKDIR /serving

CMD ["bazel-bin/tensorflow_serving/model_servers/tensorflow_model_server", "--port=9000", "--model_name=inception", "--model_base_path=inception-export"]
