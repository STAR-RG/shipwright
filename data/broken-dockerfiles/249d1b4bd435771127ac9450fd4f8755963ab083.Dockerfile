# Copyright 2014 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:trusty

RUN mkdir /deepdream
WORKDIR /deepdream

RUN apt-get -q update && \
  apt-get install --no-install-recommends -y --force-yes -q \
    build-essential \
    ca-certificates \
    git \
    python python-pip \
    python-dev libpython-dev \
    python-numpy python-scipy python-imaging \
    ipython ipython-notebook \
    libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev libboost-all-dev \
    libatlas-base-dev libgflags-dev libgoogle-glog-dev liblmdb-dev protobuf-compiler && \
  apt-get clean && \
  rm /var/lib/apt/lists/*_*

# Download and compile Caffe
RUN git clone https://github.com/BVLC/caffe
RUN cd caffe && \
  cp Makefile.config.example Makefile.config && echo "CPU_ONLY := 1" >> Makefile.config && \
  make all -j2 
RUN pip install -U pip
RUN pip install cython jupyter
RUN cd caffe && \
  pip install --requirement python/requirements.txt 
RUN cd caffe && make pycaffe -j2
RUN cd caffe && make distribute
RUN cd caffe/scripts && ./download_model_binary.py ../models/bvlc_googlenet/

RUN pip install protobuf && pip install tornado --upgrade
RUN apt-get -q update && \
  apt-get install --no-install-recommends -y --force-yes -q \
    python-jsonschema && \
  apt-get clean && \
  rm /var/lib/apt/lists/*_*

RUN git clone https://github.com/google/deepdream

# Uncomment to include DeepDream Video
# RUN git clone https://github.com/graphific/DeepDreamVideo
# RUN cd DeepDreamVideo && chmod a+x *.py

ENV LD_LIBRARY_PATH=/deepdream/caffe/distribute/lib
ENV PYTHONPATH=/deepdream/caffe/distribute/python

EXPOSE 8888

ADD start.sh start.sh

CMD ["./start.sh"]
