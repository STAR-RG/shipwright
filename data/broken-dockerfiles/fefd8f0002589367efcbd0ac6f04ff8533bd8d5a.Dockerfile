# mount the GHC source code into /home/ghc
#
#    docker run --rm -it --privileged -v `pwd`:/home/ghc alexeyraga/ghc-cross-arm /bin/bash
#

FROM quay.io/alexeyraga/ghc-7.8.4
MAINTAINER Alexey Raga

## disable prompts from apt
ENV DEBIAN_FRONTEND noninteractive

ADD ./scripts/* /etc/ghc-install/

RUN sudo /etc/ghc-install/install-deps.sh
RUN sudo /etc/ghc-install/install-linaro.sh
RUN sudo /etc/ghc-install/build-ghc.sh

ADD ./cabal-arm /opt/cabal-arm
RUN sudo chmod +x /opt/cabal-arm && sudo ln -s /opt/cabal-arm /usr/local/bin/cabal-arm
