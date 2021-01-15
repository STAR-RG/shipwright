FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y cmake gcc g++ vim mc python3
RUN apt-get install -y libpython3-dev
RUN apt-get install -y libboost-all-dev

RUN ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime
RUN apt-get install -y tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get install -y libopencv-dev
RUN apt-get install -y python-opencv python3-numpy
RUN apt-get install -y python3-pip

RUN pip3 install --upgrade pip
RUN pip3 install setuptools
RUN pip3 install opencv-python

RUN apt-get install -y libpython3-all-dev tmux

COPY . /src/

RUN mkdir -p /src/build/
WORKDIR /src/build/

RUN /bin/bash -c 'cmake -DCMAKE_INSTALL_PREFIX=/usr -DPYTHON_VERSION="3.6" -DCMAKE_CUDA_FLAGS="--expt-extended-lambda -std=c++11" .. ; echo true'

#RUN /bin/bash -c 'cmake -DCMAKE_INSTALL_PREFIX=/usr -DPYTHON_VERSION="3" -DBOOST_PYTHON_VERSION="python-py3" .. ; echo true'
RUN make -j8
RUN make install

WORKDIR /src/example
#CMD python3 /src/example/test-write-channels
