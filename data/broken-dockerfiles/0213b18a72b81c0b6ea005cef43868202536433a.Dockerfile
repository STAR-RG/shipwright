FROM debian:jessie

RUN apt-get update && apt-get install -y \
	vim \
	curl \
	wget \
	git \
	make \
	netcat \
	python \
	python2.7-dev \
	g++ \
	bzip2 \
	binutils

RUN apt-get install -y \
	libasound2 \
	libasound-dev \
	libssl-dev 

# Build py-audio

RUN git clone https://github.com/theintencity/py-audio.git /usr/local/src/py-audio

## RTAUDIO
RUN curl http://www.music.mcgill.ca/~gary/rtaudio/release/rtaudio-4.0.12.tar.gz | tar xz && \
  mv rtaudio-4.0.12 /usr/local/src/py-audio/rtaudio
WORKDIR /usr/local/src/py-audio/rtaudio/
RUN ./configure && make clean && make

## SPEEX
RUN curl http://downloads.xiph.org/releases/speex/speex-1.2rc1.tar.gz | tar xz && \
  mv speex-1.2rc1 /usr/local/src/py-audio/speex
WORKDIR /usr/local/src/py-audio/speex/
RUN ./configure && make

## FLITE
RUN curl http://www.speech.cs.cmu.edu/flite/packed/flite-1.4/flite-1.4-release.tar.bz2 | tar xj && \
  mv flite-1.4-release /usr/local/src/py-audio/flite
WORKDIR /usr/local/src/py-audio/flite/
RUN ./configure CFLAGS="-fPIC" && make

COPY setup_linux.py /usr/local/src/py-audio/
WORKDIR /usr/local/src/py-audio/

RUN python setup_linux.py -v install

## Prepare for using rtclite

# We don't need the next lines, because setup_linux.py took care of it for us.
# RUN cp build/lib.*/audio*.so .
# ENV PYTHONPATH=/usr/local/src/py-audio/
