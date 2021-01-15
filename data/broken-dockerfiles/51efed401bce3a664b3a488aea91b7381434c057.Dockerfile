FROM ubuntu:16.04

MAINTAINER Justin Shenk <shenk.justin@gmail.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        python-dev \
        python-opencv \
        python-matplotlib \
        python-numpy \
        python-pip \
        python-setuptools \
        python-scipy \
        ffmpeg && \
    rm -rf /var/lib/apt/lists/*


ENV CAFFE_ROOT=/opt/caffe
WORKDIR $CAFFE_ROOT

# FIXME: use ARG instead of ENV once DockerHub supports this
# https://github.com/docker/hub-feedback/issues/460
ENV CLONE_TAG=1.0

RUN git clone -b ${CLONE_TAG} --depth 1 https://github.com/BVLC/caffe.git . && \
    # pip install --upgrade pip && \
    pip install wheel && \
    cd python && for req in $(cat requirements.txt) pydot; do pip install $req; done && cd .. && \
    mkdir build && cd build && \
    cmake -DCPU_ONLY=1 .. && \
    make -j"$(nproc)"

ENV PYCAFFE_ROOT $CAFFE_ROOT/python
ENV PYTHONPATH $PYCAFFE_ROOT:$PYTHONPATH
ENV PATH $CAFFE_ROOT/build/tools:$PYCAFFE_ROOT:$PATH
RUN echo "$CAFFE_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

WORKDIR /root

COPY requirements.txt /root
RUN cd /root && pip install --requirement requirements.txt

COPY convert.py /root
COPY util.py /root
COPY config_reader.py /root
COPY config /root
COPY README.md /root

# Download pre-trained model
RUN cd /root && mkdir -p model/_trained_COCO && \
	wget -nc --directory-prefix=model/_trained_COCO/ http://posefs1.perception.cs.cmu.edu/Users/ZheCao/pose_iter_440000.caffemodel
COPY model/_trained_COCO/pose_deploy.prototxt /root/model/_trained_COCO

# Set up notebook config
COPY jupyter_notebook_config.py /root/.jupyter/

# Expose Ports for TensorBoard (6006), Ipython (8888)
EXPOSE 6006 8888

CMD ["/bin/bash"]
