FROM ampervue/python34

# https://github.com/ampervue/docker-python34-opencv3

MAINTAINER David Karchmer <dkarchmer@ampervue.com>

#####################################################################
#
# Image based on Ubuntu:14.04
#
#   with
#     - Python 3.4
#     - OpenCV 3 (built)
#     - FFMPEG (built)
#   plus a bunch of build/web essentials via wheezy
#   including MySQL and Postgres clients:
#      https://github.com/docker-library/docs/tree/master/buildpack-deps
#
#####################################################################

ENV NUM_CORES 4


WORKDIR /usr/local/src

RUN git clone --depth 1 https://github.com/l-smash/l-smash \
    && git clone --depth 1 git://git.videolan.org/x264.git \
    && hg clone https://bitbucket.org/multicoreware/x265 \
    && git clone --depth 1 git://source.ffmpeg.org/ffmpeg \
    && git clone https://github.com/Itseez/opencv.git \
    && git clone https://github.com/Itseez/opencv_contrib.git \
    && git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git \
    && git clone --depth 1 https://chromium.googlesource.com/webm/libvpx \
    && git clone https://git.xiph.org/opus.git \
    && git clone --depth 1 https://github.com/mulx/aacgain.git

# Build L-SMASH
# =================================
WORKDIR /usr/local/src/l-smash
RUN ./configure \
    && make -j ${NUM_CORES} \
    && make install
# =================================


# Build libx264
# =================================
WORKDIR /usr/local/src/x264
RUN ./configure --enable-static \
    && make -j ${NUM_CORES} \
    && make install
# =================================


# Build libx265
# =================================
WORKDIR  /usr/local/src/x265/build/linux
RUN cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr ../../source \
    && make -j ${NUM_CORES} \
    && make install
# =================================

# Build libfdk-aac
# =================================
WORKDIR /usr/local/src/fdk-aac
RUN autoreconf -fiv \
    && ./configure --disable-shared \
    && make -j ${NUM_CORES} \
    && make install
# =================================

# Build libvpx
# =================================
WORKDIR /usr/local/src/libvpx
RUN ./configure --disable-examples \
    && make -j ${NUM_CORES} \
    && make install
# =================================

# Build libopus
# =================================
WORKDIR /usr/local/src/opus
RUN ./autogen.sh \
    && ./configure --disable-shared \
    && make -j ${NUM_CORES} \
    && make install
# =================================



# Build OpenCV 3.x
# =================================
#RUN apt-get update -qq && apt-get install -y --force-yes libopencv-dev
RUN pip3 install --no-cache-dir --upgrade numpy
WORKDIR /usr/local/src
RUN mkdir -p opencv/release
WORKDIR /usr/local/src/opencv/release
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON \
          -D BUILD_PYTHON_SUPPORT=ON \
          -D WITH_V4L=ON \
          -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
          ..

RUN make -j ${NUM_CORES} \
    && make install \
    && sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf' \
    && ldconfig
# =================================


# Build ffmpeg.
# =================================
RUN apt-get update -qq && apt-get install -y --force-yes \
    libass-dev

#            --enable-libx265 - Does not work on recent builds
WORKDIR /usr/local/src/ffmpeg
RUN ./configure --extra-libs="-ldl" \
            --enable-gpl \
            --enable-libass \
            --enable-libfdk-aac \
            --enable-libfontconfig \
            --enable-libfreetype \
            --enable-libfribidi \
            --enable-libmp3lame \
            --enable-libopus \
            --enable-libtheora \
            --enable-libvorbis \
            --enable-libvpx \
            --enable-libx264 \
            --enable-nonfree \
    && make -j ${NUM_CORES} \
    && make install
# =================================


# Remove all tmpfile
# =================================
WORKDIR /usr/local/
RUN rm -rf /usr/local/src
# =================================

