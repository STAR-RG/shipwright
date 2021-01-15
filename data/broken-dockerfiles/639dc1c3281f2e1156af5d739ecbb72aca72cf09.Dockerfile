FROM debian:stable-slim
ENV HOME /root
WORKDIR $HOME

RUN apt-get update && apt-get install -y git
RUN git clone git://git.sv.gnu.org/gnulib.git
ENV GNULIB_SRCDIR $HOME/gnulib

RUN mkdir app
WORKDIR app

RUN apt-get update && apt-get install -y make autoconf automake autopoint gcc

COPY bootstrap bootstrap.conf configure.ac Makefile.am ./
COPY NEWS README* AUTHORS ChangeLog COPYING* ./

COPY src/ ./src/

RUN ./bootstrap --skip-po
RUN ./configure
RUN make clean
RUN make
RUN make install
