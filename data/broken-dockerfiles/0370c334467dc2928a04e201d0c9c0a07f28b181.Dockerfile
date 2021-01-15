FROM alpine:3.6
MAINTAINER Kitware, Inc. <kitware@kitware.com>

RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && apk add \
    bash \
    python python-dev \
    py-pip \
    gdal@testing gdal-dev@testing \
    py-gdal@testing \
    geos@testing geos-dev@testing \
    linux-headers \
    boost-dev \
    zlib zlib-dev \
    freetype freetype-dev \
    harfbuzz harfbuzz-dev \
    jpeg jpeg-dev \
    proj4@testing proj4-dev@testing \
    tiff tiff-dev \
    cairo cairo-dev \
    postgresql postgresql-dev \
    py-numpy \
    uwsgi

RUN apk add gcc make g++ git && \
    git clone https://github.com/mapnik/mapnik.git -b v3.0.13 /opt/mapnik && \
    cd /opt/mapnik && \
    git submodule update --init deps/mapbox/variant && \
    ./configure && \
    JOBS=$(grep -c ^processor /proc/cpuinfo) make && \
    make install && \
    git clone https://github.com/mapnik/python-mapnik.git -b v3.0.13 /opt/python-mapnik && \
    cd /opt/python-mapnik && \
    python setup.py install && \
    rm -rf /opt/python-mapnik /opt/mapnik

COPY . /opt/ktile

RUN cd /opt/ktile && \
    pip install -r requirements.txt && pip install .

VOLUME /opt/ktile

RUN apk del gcc make g++ git

WORKDIR /opt/ktile

ENTRYPOINT ["/opt/ktile/docker-entrypoint.sh"]
