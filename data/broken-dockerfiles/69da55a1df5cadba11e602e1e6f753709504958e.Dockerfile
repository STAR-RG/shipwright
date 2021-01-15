FROM ubuntu:14.04
MAINTAINER Zach Mullen <zach.mullen@kitware.com>

RUN mkdir /covalic
RUN mkdir /covalic/_build

WORKDIR /covalic/_build
COPY CMake /covalic/CMake
COPY Code /covalic/Code
COPY Documentation /covalic/Documentation
COPY Utilities /covalic/Utilities
COPY CMakeLists.txt /covalic/CMakeLists.txt
COPY Python /covalic/Python

# Install system prerequisites
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    freeglut3-dev \
    git \
    mesa-common-dev \
    python \
    python-pip \
    libpython-dev \
    liblapack-dev \
    gfortran

RUN pip install numpy scipy

# Perform superbuild of covalic scoring metrics
RUN cmake -DBUILD_TESTING:BOOL=OFF /covalic
RUN make -j2

ENTRYPOINT ["python", "/covalic/Python/scoreSubmission.py"]
