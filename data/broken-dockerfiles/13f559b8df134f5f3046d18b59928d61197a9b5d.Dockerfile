#
# Builds OpenCV3 environment
# If building on OSX or Windows you want to add at least 4 cores to the VirtualBox 
# Boot2Docker machine to build OpenCV3
#

FROM debian:jessie

MAINTAINER Willem Prins <willem.prins@admobilize.com>

ENV OPENCV_VERSION=3.1.0 

RUN apt-get update && apt-get -yq install \
  build-essential \
  cmake \
  ccache \  
  curl \ 
  gfortran \
  git \
  libjpeg-dev \
  libtiff5-dev \
  libjasper-dev \
  libpng12-dev \
  libavcodec-dev \
  libavformat-dev \
  libgstreamer0.10-dev \
  libgstreamer-plugins-base0.10-dev \
  libgtk2.0-dev \
  libswscale-dev \ 
  libv4l-dev \ 
  libatlas-base-dev \
  libfreetype6-dev \
  libxvidcore-dev \
  libx264-dev \
  libtbb-dev \
  libavutil-dev \
  libavdevice-dev \
  libavfilter-dev \
  libavresample-dev \
  libpostproc-dev \
  libopenexr-dev \
  libssl-dev \
  libcurl4-openssl-dev \
  libpthread-stubs0-dev \
  pkg-config \
  python-dev \
  vim \
  yasm \
  && apt-get clean && rm -rf /var/tmp/* /var/lib/apt/lists/* /tmp/*

# ---------------------------------------Node JS ---------------------------------------------
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 5.3.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc

RUN npm install -g node-gyp

# ------------------------------------- OpenCV ----------------------------------------
RUN mkdir -p /opt/src/opencv-${OPENCV_VERSION}/build \
  && curl -sLo /opt/src/opencv3.tar.gz \
     https://github.com/Itseez/opencv/archive/${OPENCV_VERSION}.tar.gz \
  && tar -xzvf /opt/src/opencv3.tar.gz -C /opt/src \
  && cd /opt/src/opencv-${OPENCV_VERSION}/build \
  && cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D WITH_TBB=ON \
    -D WITH_IPP=OFF \
    -D WITH_OPENMP=ON \
    -D WITH_GSTREAMER=ON .. \ 
  && make -j "$(nproc)" \
  && make install \
  && ldconfig -v \
  && rm -rf /opt/src

# ----------------------------------- nlohmann/json ---------------------------------------
RUN mkdir -p /opt/src/json/build \
  && curl -Lo /opt/src/json.tar.gz https://github.com/nlohmann/json/tarball/master \
  && tar -xzvf /opt/src/json.tar.gz -C /opt/src/json --strip-components=1 \
  && mv /opt/src/json/src/json.hpp /usr/include \
  && rm -rf /opt/sr

#---------------------------------- Gesture ---------------------------------------

RUN git clone https://github.com/matrix-io/matrix-gesture-cpp-sdk.git /root/gesture-cpp-sdk \
  && git clone https://github.com/matrix-io/matrix-gesture-node-sdk.git /root/gesture-node-sdk

RUN cd /root/gesture-node-sdk \
  && npm install \
  && npm run root-setup
