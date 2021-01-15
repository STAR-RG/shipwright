ARG UBUNTU_VERSION=xenial

# Intermediate builder container
FROM ubuntu:${UBUNTU_VERSION} as builder
ARG UBUNTU_VERSION
ARG SRSLTE_REPO=https://github.com/srsLTE/srsLTE
ARG SRSLTE_CHECKOUT=master

# Install build dependencies
RUN echo "deb http://ppa.launchpad.net/ettusresearch/uhd/ubuntu \
          ${UBUNTU_VERSION} main" > /etc/apt/sources.list.d/uhd-latest.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6169358E \
 && apt-get update \
 && apt-get install -y \
        build-essential \
        git \
        cmake \
        libuhd-dev \
        uhd-host \
        libboost-all-dev \
        # warning: pulled libboost-all-dev because libboost(-dev) alone left
        # cmake unable to find boost when building the makefiles for srsUE
        libvolk1-dev \
        libfftw3-dev \
        libmbedtls-dev \
        libsctp-dev \
        libconfig++-dev \
 && rm -rf /var/lib/apt/lists/*

# Clone repo and build
RUN mkdir /srslte \
 && cd /srslte \
 && git clone $SRSLTE_REPO srslte \
 && cd srslte \
 && git checkout $SRSLTE_CHECKOUT \
 && cd .. \
 && mkdir build \
 && cd build \
 && cmake -DCMAKE_INSTALL_PREFIX:PATH=/opt/srslte ../srslte \
 && make -j$(ncore) install

# Copy the examples over
RUN cd /srslte/build/lib/examples && cp $(ls | grep -vi make) /opt/srslte/bin

# Final container
FROM ubuntu:${UBUNTU_VERSION}
ARG UBUNTU_VERSION

# Install runtime dependencies
RUN echo "deb http://ppa.launchpad.net/ettusresearch/uhd/ubuntu \
          ${UBUNTU_VERSION} main" > /etc/apt/sources.list.d/uhd-latest.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6169358E \
 && apt-get update \
 && apt-get install -y \
        uhd-host \
        libuhd003 \
       libvolk1.1 \
       libfftw3-3 \
       libmbedtls10 \
       libsctp1 \
       libconfig++9v5 \
 && python /usr/lib/uhd/utils/uhd_images_downloader.py \
 && rm -rf /var/lib/apt/lists/*

# Get compiled srsLTE
COPY --from=builder /opt/srslte /opt/srslte

# Set up paths
ENV LD_LIBRARY_PATH /opt/srslte/lib:$LD_LIBRARY_PATH
ENV PATH /opt/srslte/bin:$PATH

WORKDIR /conf
