FROM        ubuntu:xenial
MAINTAINER  Kevin Chen <k_@berkeley.edu>

# Setup environment.
ENV PATH /opt/ghc/bin:$HOME/.local/bin:$PATH

# Default command on startup.
CMD bash

# Setup packages.
RUN apt-get update && apt-get -y install git curl autoconf libtool
RUN curl -sSL https://get.haskellstack.org/ | sh

RUN stack build
