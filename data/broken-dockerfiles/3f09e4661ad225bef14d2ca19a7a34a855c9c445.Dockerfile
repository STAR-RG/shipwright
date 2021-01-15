FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y build-essential libatlas-base-dev python-dev python-pip git automake autoconf libtool
RUN apt-get install -y wget
RUN apt-get install -y mc
RUN apt-get install -y graphviz
RUN pip2 install jupyter

RUN wget http://www.openfst.org/twiki/pub/FST/FstDownload/openfst-1.3.4.tar.gz
RUN tar -zxvf openfst-1.3.4.tar.gz

RUN wget https://raw.githubusercontent.com/kaldi-asr/kaldi/master/tools/extras/openfst-1.3.4.patch
RUN cd openfst-1.3.4/src/include/fst; \
    patch -c -p0 -N < /openfst-1.3.4.patch

RUN cd openfst-1.3.4; \
    ./configure --prefix=`pwd` --enable-static --with-pic --enable-shared --enable-far --enable-ngram-fsts; \
    make -j 4; \
    make install

COPY . /pyfst

WORKDIR /pyfst

RUN pip install -r requirements.txt

ENV FST=/openfst-1.3.4
ENV LD_LIBRARY_PATH=$FST/lib:$FST/lib/fst:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=$FST/lib:$FST/lib/fst
ENV CPLUS_INCLUDE_PATH=$FST/include

RUN python setup.py install

WORKDIR /

VOLUME /pyfst/notebooks