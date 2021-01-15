FROM alpine:3.9
MAINTAINER Anton Wahyu <mail@anton.web.id>

ENV WKHTMLTOPDF_VERSION=tags/0.12.5
# install qt build packages #
RUN apk update \
  && apk add gtk+ openssl glib fontconfig libstdc++ bash vim \
  && apk add --virtual .deps git patch make g++ \
    libc-dev gettext-dev zlib-dev bzip2-dev libffi-dev pcre-dev \
    glib-dev atk-dev expat-dev libpng-dev freetype-dev fontconfig-dev \
    libxau-dev libxdmcp-dev libxcb-dev  libx11-dev \
    libxrender-dev pixman-dev libxext-dev cairo-dev perl-dev \
    libxfixes-dev libxdamage-dev graphite2-dev icu-dev harfbuzz-dev \
    libxft-dev pango-dev gtk+-dev libdrm-dev \
    libxxf86vm-dev libxshmfence-dev wayland-dev mesa-dev openssl-dev \
  && git clone --recursive https://github.com/wkhtmltopdf/wkhtmltopdf.git /tmp/wkhtmltopdf \
  && cd /tmp/wkhtmltopdf \
  && git checkout $WKHTMLTOPDF_VERSION

COPY conf/* /tmp/wkhtmltopdf/qt/

RUN	cd /tmp/wkhtmltopdf/qt && \
  patch -p1 -i qt-musl.patch && \
  patch -p1 -i qt-musl-iconv-no-bom.patch && \
  patch -p1 -i qt-recursive-global-mutex.patch && \
  patch -p1 -i qt-gcc8.patch && \
  CFLAGS=-w CPPFLAGS=-w CXXFLAGS=-w LDFLAGS=-w \
  ./configure -confirm-license -opensource \
    -prefix /usr \
    -datadir /usr/share/qt \
    -sysconfdir /etc \
    -plugindir /usr/lib/qt/plugins \
    -importdir /usr/lib/qt/imports \
    -fast \
    -release \
    -static \
    -largefile \
    -glib \
    -graphicssystem raster \
    -qt-zlib \
    -qt-libpng \
    -qt-libmng \
    -qt-libtiff \
    -qt-libjpeg \
    -svg \
    -script \
    -webkit \
    -gtkstyle \
    -xmlpatterns \
    -script \
    -scripttools \
    -openssl-linked \
    -nomake demos \
    -nomake docs \
    -nomake examples \
    -nomake tools \
    -nomake tests \
    -nomake translations \
    -no-qt3support \
    -no-pch \
    -no-icu \
    -no-phonon \
    -no-phonon-backend \
    -no-rpath \
    -no-separate-debug-info \
    -no-dbus \
    -no-opengl \
    -no-openvg && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  export MAKEFLAGS=-j${NPROC} && \
  export MAKE_COMMAND="make -j${NPROC}" && \
  make --silent && \
  make install && \
  cd /tmp/wkhtmltopdf && \
  qmake && \
  make --silent && \
  make install && \
  rm -rf /tmp/* \
  # remove qt build packages #
  && apk del .deps \
  && rm -rf /var/cache/apk/*
