FROM ubuntu:14.04
MAINTAINER Allan Pinto <allansp84@gmail.com>

# -- updating the system and installing dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libjasper-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libtiff5 \
    libtiff5-dev \
    libtiff-tools \
    libfreetype6-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libdc1394-22-dev \
    libopenblas-dev \
    libblitz0-dev \
    libboost-all-dev \
    libtbb2 \
    libtbb-dev \
    libhdf5-serial-dev \
    libgtk2.0-dev \
    pkg-config \
    giflib-dbg \
    libcppnetlib-dev \
    python-netlib \
    python-pip \
    python-dev \
    python-numpy \
    python-urllib3 \
    cmake \
    git \
    wget \
    vim \
    unzip \
    libpython-dev

# -- update pip and install virtualenv
RUN pip install --upgrade pip setuptools

# -- general environment variable
ENV HOME_DIR=/root
ENV INSTALLERS_DIR=$HOME_DIR/installers
ENV PREFIX_INSTALL=/usr/local

# -- installing OpenCV
ENV OPENCV_VERSION=2.4.13
ENV OPENCV_FOLDER=$INSTALLERS_DIR/opencv-$OPENCV_VERSION
ENV OPENCV_FILENAME=opencv-$OPENCV_VERSION.zip

WORKDIR $INSTALLERS_DIR
ADD https://github.com/opencv/opencv/archive/$OPENCV_VERSION/$OPENCV_FILENAME $INSTALLERS_DIR
RUN unzip $INSTALLERS_DIR/$OPENCV_FILENAME

WORKDIR $OPENCV_FOLDER

RUN mkdir -p release
WORKDIR release

RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=$PREFIX_INSTALL \
    -D BUILD_NEW_PYTHON_SUPPORT=ON \
    -D WITH_CUDA=OFF \
    -D WITH_OPENMP=YES \
    -D WITH_CUBLAS=YES \
    -D INSTALL_C_EXAMPLES=ON \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D BUILD_EXAMPLES=ON \
    -D WITH_1394=OFF \
    ..

RUN make -j"$(nproc)" && make install

RUN python -c "import cv2; print cv2.__version__"

WORKDIR $HOME_DIR

# -- copy source code to the docker
RUN git clone https://github.com/allansp84/spectralcubes.git

# -- installing spectralcubes dependencies
WORKDIR spectralcubes
RUN pip install --requirement requirements.txt && python setup.py install

WORKDIR $HOME_DIR

# -- clean up opencv
RUN rm -rf $INSTALLERS_DIR
