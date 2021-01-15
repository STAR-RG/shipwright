FROM tensorflow/tensorflow:latest-py3

MAINTAINER Gregory Zhigalov <zhigalov8@gmail.com>

LABEL description="tensorflow 1.1.0, python 3.5.2, opencv 3.2.0, and freetype 1.0.2."

ENV PYTHONPATH /home

# Install python packages required.

RUN pip install fonttools==3.6.2 \
    freetype-py==1.0.2 \
    h5py==2.6.0 \
    pdfrw==0.3 \
    pymysql==0.7.9 \
    PyPDF2==1.26.0 \
    PyQt5==5.8 \
    pytest==2.8.5 \
    reportlab==3.3.0 \
    simplejson==3.10.0 \
    sphinx==1.3.1 \
    SQLAlchemy==1.0.12

# Install build library.

RUN apt-get update && \
    apt-get install -y \
    cmake \
    wget \
    git \
    yasm \
    libjpeg-dev \
    libtiff-dev \
    libjasper-dev \
    libpng-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libatlas-base-dev \
    gfortran \
    libtbb2 \
    libtbb-dev \
    libpq-dev \
    libgtk2.0-dev \
    vim \
    && apt-get -y clean all \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /

# Download opencv and opencv_contrib

RUN wget https://github.com/Itseez/opencv/archive/3.2.0.zip -O opencv.zip \
    && unzip opencv.zip \
    && wget https://github.com/Itseez/opencv_contrib/archive/3.2.0.zip -O opencv_contrib.zip \
    && unzip opencv_contrib \
    && mkdir /opencv-3.2.0/cmake_binary

# Make and install opencv.

RUN cd /opencv-3.2.0/cmake_binary \
    && cmake -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib-3.2.0/modules \
    -DBUILD_TIFF=ON \
    -DBUILD_opencv_java=OFF \
    -DWITH_CUDA=OFF \
    -DENABLE_AVX=ON \
    -DWITH_OPENGL=ON \
    -DWITH_OPENCL=ON \
    -DWITH_IPP=ON \
    -DWITH_TBB=ON \
    -DWITH_EIGEN=ON \
    -DWITH_V4L=ON \
    -DBUILD_TESTS=OFF \
    -DBUILD_PERF_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DBUILD_opencv_python3=ON \
    -DCMAKE_INSTALL_PREFIX=$(python3.5 -c "import sys; print(sys.prefix)") \
    -DPYTHON_EXECUTABLE=$(which python3.5) \
    -DPYTHON_INCLUDE_DIR=$(python3.5 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
    -DPYTHON_PACKAGES_PATH=$(python3.5 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
    && make install \
    && rm /opencv.zip \
    && rm /opencv_contrib.zip \
    && rm -r /opencv-3.2.0 \
    && rm -r /opencv_contrib-3.2.0 \
    && cd /usr/lib/python3.5/dist-packages \
    && ln -s cv2.cpython-35m-x86_64-linux-gnu.so cv2.so

EXPOSE 6006 8888

WORKDIR /home

VOLUME ["/home"]

CMD ["/bin/bash"]