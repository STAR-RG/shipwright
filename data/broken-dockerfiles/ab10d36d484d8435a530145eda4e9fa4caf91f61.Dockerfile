#FROM alanz/haskell-ghc-7.6.3-64
FROM alanz/haskell-ghc-7.8-64
#FROM alanz/haskell-platform-2013.2-deb64

# Build with
# docker build -t alanz/htelehash .

MAINTAINER alan.zimm@gmail.com

ENV DEBIAN_FRONTEND noninteractive


######### cabal-install ################################################

#RUN echo "1" && apt-get update
#RUN echo "2" && apt-get update
RUN echo "3" && apt-get update

RUN echo "1" && apt-get -y dist-upgrade

RUN apt-get -y install zlib1g-dev wget locales locales-all

RUN wget http://www.haskell.org/cabal/release/cabal-install-1.20.0.2/cabal-install-1.20.0.2.tar.gz
RUN tar xvfz cabal-install-1.20.0.2.tar.gz
RUN (cd cabal-install-1.20.0.2 && ./bootstrap.sh)
RUN rm -fr cabal-install-1.20.0.2*

########################################################################

ENV CABAL //.cabal/bin/cabal
ENV DIR  ./htelehash

#RUN $CABAL update
RUN echo "1" && $CABAL update

ADD . $DIR
RUN ls $DIR

# This is a locale-related error. Check that LANG is set to e.g.
# en_US.UTF-8, or another UTF-8 locale. Check that locale files are
# available on the system.
RUN LANG=en_US.UTF-8 locale-gen --purge en_US.UTF-8
#RUN locale-gen
#ENV LANG en_US.UTF-8
ENV LANG C.UTF-8
RUN locale -a

RUN cd $DIR && rm -fr .cabal-sandbox cabal.sandbox.config
RUN cd $DIR && $CABAL clean
RUN cd $DIR && $CABAL sandbox init
RUN cd $DIR && $CABAL list unix-compat
RUN cd $DIR && $CABAL install unix-compat
#RUN cd $DIR && $CABAL install happy
#RUN cd $DIR && $CABAL install crypto-random
#RUN cd $DIR && $CABAL install hscolour
RUN cd $DIR && $CABAL install --dependencies-only
RUN cd $DIR && $CABAL install
