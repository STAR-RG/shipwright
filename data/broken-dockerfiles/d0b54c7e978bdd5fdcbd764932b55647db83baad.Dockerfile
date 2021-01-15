ARG CUDA
From nvidia/cuda:${CUDA}-devel
ARG CUDA

RUN apt-get update && apt-get install -y python-pip python-dev build-essential libyaml-dev git wget xml-twig-tools libsort-naturally-perl default-jre sox cmake mercurial
RUN pip install --upgrade pip
RUN cd /opt && \
    git clone https://github.com/isl-mt/SLT.KIT.git
#PyTorch
RUN /opt/SLT.KIT/DownloadPyTorch.sh ${CUDA}
RUN pip install torchvision
RUN pip install -U numpy
RUN pip install nltk
RUN pip install subword-nmt

RUN cd /opt && \
    git clone https://github.com/quanpn90/OpenNMT-py

RUN cd /opt && \
    git clone https://github.com/moses-smt/mosesdecoder.git

RUN cd /opt && \
    git clone https://github.com/rsennrich/subword-nmt.git

RUN cd /opt && \
    wget http://www.cs.umd.edu/%7Esnover/tercom/tercom-0.7.25.tgz && \
    tar xfvz tercom-0.7.25.tgz

RUN cd /opt && wget https://raw.githubusercontent.com/stanojevic/beer/master/packaged/beer_2.0.tar.gz && tar xfvz beer_2.0.tar.gz
RUN cd /opt && git clone https://github.com/rwth-i6/CharacTER.git
RUN cd /opt && wget https://www-i6.informatik.rwth-aachen.de/web/Software/mwerSegmenter.tar.gz && tar xzvf mwerSegmenter.tar.gz

# Speaker Diarization
RUN cd /opt && \
    wget --no-check-certificate https://git-lium.univ-lemans.fr/Meignier/lium-spkdiarization/raw/660f866a9b80442d721c3454c9e59b3b62d8eab9/jar/lium_spkdiarization-8.4.1.jar.gz && \
    gunzip lium_spkdiarization-8.4.1.jar.gz

# Anaconda
RUN wget https://repo.continuum.io/archive/Anaconda3-5.1.0-Linux-x86_64.sh
RUN chmod 755 Anaconda3*.sh
RUN ./Anaconda3*.sh -b
RUN /root/anaconda3/bin/pip install --upgrade pip

# DyNet
RUN cd /opt && hg clone https://bitbucket.org/eigen/eigen/ -r b2e267d
RUN cd /opt && git clone https://github.com/clab/dynet.git && mkdir -p /opt/dynet/build
RUN cd /opt/dynet/build && cmake /opt/dynet -DEIGEN3_INCLUDE_DIR=/opt/eigen -DBACKEND=cuda -DPYTHON=/root/anaconda3/bin/python && make
RUN cd /opt/dynet/build/python && /root/anaconda3/bin/python /opt/dynet/setup.py build --build-dir=/opt/dynet/build --skip-build install

# XNMT
RUN cd /opt && git clone -b iwslt2018 https://github.com/neulab/xnmt.git && cd /opt/xnmt && /root/anaconda3/bin/pip install -r requirements.txt && /root/anaconda3/bin/pip install -r requirements-extra.txt && /root/anaconda3/bin/python setup.py install

# PYTORCH-CTC
## CTC.ISL
RUN /opt/SLT.KIT/DownloadPyTorch-Anaconda.sh ${CUDA}
RUN /root/anaconda3/bin/pip install torchvision
RUN cd /opt && \
    git clone https://github.com/markus-m-u-e-l-l-e-r/CTC.ISL && cd CTC.ISL && /root/anaconda3/bin/pip install -r requirements.txt
## warp-ctc and pytorch binding
RUN cd /opt && \
    git clone https://github.com/SeanNaren/warp-ctc/ && cd /opt/warp-ctc && git reset --hard 8cdd6e57913e8f54d620cc8d07069c76167e7daa
RUN mkdir /opt/warp-ctc/build && cd /opt/warp-ctc/build && cmake .. && make
RUN export CUDA_HOME="/usr/local/cuda" && cd /opt/warp-ctc/pytorch_binding && /root/anaconda3/bin/python setup.py install

# ASR Scoring NIST Scoring Toolkit
RUN cd /opt && wget http://www.openslr.org/resources/4/sctk-2.4.10-20151007-1312Z.tar.bz2 && tar jxf sctk-2.4.10-20151007-1312Z.tar.bz2 && rm sctk-2.4.10-20151007-1312Z.tar.bz2
RUN cd /opt/sctk-2.4.10 && make config && make all && make install && make doc

