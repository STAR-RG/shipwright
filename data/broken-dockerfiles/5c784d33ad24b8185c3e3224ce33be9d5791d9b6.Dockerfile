# This file creates a container with the GHC Haskell Platform
# installed and ready to use.
#
# Author: Martin Rehfeld
# Date: 09/05/2013

FROM ubuntu:12.10
MAINTAINER Martin Rehfeld <martin.rehfeld@glnetworks.de>

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y # DATE: 2013-09-05
ENV DEBIAN_FRONTEND noninteractive

# Installing the required packages
RUN apt-get install -y build-essential libedit2 libglu1-mesa-dev libgmp3-dev libgmp3c2 zlib1g-dev freeglut3-dev wget

# Download and extract GHC and the Haskell Platform
RUN wget -q http://www.haskell.org/ghc/dist/7.6.3/ghc-7.6.3-x86_64-unknown-linux.tar.bz2
RUN tar xjf ghc-7.6.3-x86_64-unknown-linux.tar.bz2
RUN rm ghc-7.6.3-x86_64-unknown-linux.tar.bz2
RUN wget -q http://lambda.haskell.org/platform/download/2013.2.0.0/haskell-platform-2013.2.0.0.tar.gz
RUN tar xzf haskell-platform-2013.2.0.0.tar.gz
RUN rm haskell-platform-2013.2.0.0.tar.gz

# Build and install GHC
RUN cd ghc-7.6.3; ./configure && make install

# Build and install the Haskell Platform
RUN cd haskell-platform-2013.2.0.0; ./configure && make && make install

# Clean up build files
RUN rm -rf ghc-7.6.3 haskell-platform-2013.2.0.0

# Update Hackage package list and cabal-install
RUN cabal update

# Enable library-profiling
RUN sed -E 's/(-- )?(library-profiling: )False/\2True/' -i .cabal/config

# Update cabal-install
RUN cabal install cabal-install
