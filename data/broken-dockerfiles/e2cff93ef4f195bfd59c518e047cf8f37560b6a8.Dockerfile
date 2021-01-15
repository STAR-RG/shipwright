# Use Ubuntu Artful LTS
FROM ubuntu:artful-20180123

# Pre-cache neurodebian key
COPY .docker/neurodebian.gpg /etc/.neurodebian.gpg

# Prepare environment
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                    curl \
                    bzip2 \
                    ca-certificates \
                    xvfb \
                    pkg-config && \
    curl -sSL http://neuro.debian.net/lists/trusty.us-ca.full >> /etc/apt/sources.list.d/neurodebian.sources.list && \
    apt-key add /etc/.neurodebian.gpg && \
    (apt-key adv --refresh-keys --keyserver hkp://ha.pool.sks-keyservers.net 0xA5D32F012649A5A9 || true) && \
    apt-get update

# Installing Ubuntu packages and cleaning up
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
                    libinsighttoolkit4-dev \
                    cmake \
                    g++ \
                    build-essential \
                    libjsoncpp-dev \
                    libvtk6-dev \
                    libvtkgdcm2-dev \
                    libboost-filesystem-dev \
                    libboost-system-dev \
                    libboost-program-options-dev \
                    libfftw3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


COPY ./Code /src/regseg

WORKDIR /usr/local/build/regseg/
RUN cmake /src/regseg/ -G"Unix Makefiles"  -DCMAKE_BUILD_TYPE=Release -DITK_DIR=/usr/local/lib/cmake/ITK-4.7/ -DVTK_DIR=/usr/lib/cmake/vtk-6.0/ && \
    make -j$( grep -c ^processor /proc/cpuinfo ) && \
    make install && \
    rm -rf /src/regseg/ /usr/local/build/regseg/

ENTRYPOINT ["/usr/local/bin/regseg"]

# Store metadata
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="RegSeg" \
      org.label-schema.description="RegSeg -" \
      org.label-schema.url="https://github.com/oesteban/RegSeg" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/oesteban/RegSeg" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

WORKDIR /work
