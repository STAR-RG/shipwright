
FROM jupyter/scipy-notebook

MAINTAINER Tom Rafferty <traff.td@gmail.com>

########################################
#
# Image based on jupyter/scipy-notebook
#
#   added OpenCV 3.1.0 (built)
#   plus prerequisites...
#######################################

USER root

# Install opencv prerequisites...
RUN apt-get update -qq && apt-get install -y --force-yes \
    curl \
    git \
    g++ \
    autoconf \
    automake \
    build-essential \
    checkinstall \
    cmake \
    pkg-config \
    yasm \
    libtiff5-dev \
    libpng-dev \
    libjpeg-dev \
    libjasper-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libdc1394-22-dev \
    libxine2-dev \
    libgstreamer0.10-dev \
    libgstreamer-plugins-base0.10-dev \
    libv4l-dev \
    libtbb-dev \
    libgtk2.0-dev \
    libmp3lame-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libtheora-dev \
    libvorbis-dev \
    libxvidcore-dev \
    libtool \
    v4l-utils \
    default-jdk \
    wget \
    tmux \
    libqt4-dev \
    libphonon-dev \
    libxml2-dev \
    libxslt1-dev \
    qtmobility-dev \
    libqtwebkit-dev \
    unzip; \
    apt-get clean

# Build OpenCV 3.x
# =================================
WORKDIR /usr/local/src
RUN git clone --branch 3.1.0 --depth 1 https://github.com/Itseez/opencv.git
RUN git clone --branch 3.1.0 --depth 1 https://github.com/Itseez/opencv_contrib.git
RUN mkdir -p opencv/release
WORKDIR /usr/local/src/opencv/release
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_TBB=ON \
          -D BUILD_PYTHON_SUPPORT=ON \
          -D WITH_V4L=ON \
#          -D INSTALL_C_EXAMPLES=ON \     bug w/ tag=3.1.0: cmake has error
          -D INSTALL_PYTHON_EXAMPLES=ON \
          -D BUILD_EXAMPLES=ON \
          -D BUILD_DOCS=ON \
          -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib/modules \
          -D WITH_XIMEA=YES \
#          -D WITH_QT=YES \
          -D WITH_FFMPEG=YES \
          -D WITH_PVAPI=YES \
          -D WITH_GSTREAMER=YES \
          -D WITH_TIFF=YES \
          -D WITH_OPENCL=YES \
          -D PYTHON2_EXECUTABLE=/opt/conda/envs/python2/bin/python \
          -D PYTHON2_INCLUDE_DIR=/opt/conda/envs/python2/include/python2.7 \
          -D PYTHON2_LIBRARIES=/opt/conda/envs/python2/lib/libpython2.7.so \
          -D PYTHON2_PACKAGES_PATH=/opt/conda/envs/python2/lib/python2.7/site-packages \
          -D PYTHON2_NUMPY_INCLUDE_DIRS=/opt/conda/envs/python2/lib/python2.7/site-packages/numpy/core/include/ \
          -D BUILD_opencv_python3=ON \
          -D PYTHON3_EXECUTABLE=/opt/conda/bin/python \
          -D PYTHON3_INCLUDE_DIR=/opt/conda/include/python3.4m/ \
          -D PYTHON3_LIBRARY=/opt/conda/lib/libpython3.so \
          -D PYTHON_LIBRARY=/opt/conda/lib/libpython3.so \
          -D PYTHON3_PACKAGES_PATH=/opt/conda/lib/python3.4/site-packages \
          -D PYTHON3_NUMPY_INCLUDE_DIRS=/opt/conda/lib/python3.4/site-packages/numpy/core/include/ \
          ..
RUN make -j4
RUN make install
RUN sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
RUN ldconfig
#
## Additional python modules
RUN /opt/conda/envs/python2/bin/pip install imutils
RUN /opt/conda/bin/pip install imutils

## =================================

## Post install mods:

# Bug in Anaconda distribution causes `GLIBC_2.15' not found error. Here is workaround:
Run mv /opt/conda/lib/libm.so /opt/conda/lib/libmXXX.so
Run mv /opt/conda/lib/libm.so.6 /opt/conda/lib/libm.so.6XXX

## Switch back to jupyter user (for now)
USER jovyan

WORKDIR /data
