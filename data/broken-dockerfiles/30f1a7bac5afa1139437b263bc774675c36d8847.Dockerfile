FROM ubuntu:14.04

RUN apt-get -y update
RUN apt-get -y install software-properties-common
RUN apt-get -y install git
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get -y install gcc-4.9
RUN apt-get -y install autoconf
RUN apt-get -y install libtool
RUN apt-get -y install make
RUN apt-get -y install libgmp3-dev
RUN apt-get -y install libmpfr-dev libmpfr-doc libmpfr4 libmpfr4-dbg
RUN apt-get -y install libssl-dev
RUN apt-get -y install python3 python3-dev python3-setuptools
RUN apt-get -y install flex bison

RUN apt-get -y install wget
RUN apt-get -y install tar

RUN wget https://crypto.stanford.edu/pbc/files/pbc-0.5.14.tar.gz
RUN tar xvvf pbc-0.5.14.tar.gz
WORKDIR pbc-0.5.14/
RUN ./configure && make install && make
WORKDIR /

RUN git clone --recursive https://github.com/kevinlewi/fhipe
WORKDIR fhipe
RUN export CFLAGS="-O3"
RUN make install

RUN python3 tests/test_ipe.py

