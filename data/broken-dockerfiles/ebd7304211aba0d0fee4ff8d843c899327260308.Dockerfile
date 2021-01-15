FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

RUN apt-get update

RUN apt-get install -y build-essential cmake wget curl sudo git autotools-dev pkg-config autoconf libopenmpi-dev vim tree zip g++ zlib1g-dev unzip libeigen3-dev \
	software-properties-common python-software-properties \
	libgles2-mesa-dev freeglut3-dev mesa-utils-extra libglfw3-dev libosmesa6-dev

# Install java
RUN \
	echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
	add-apt-repository -y ppa:webupd8team/java && \
	apt-get update && \
	apt-get install -y oracle-java8-installer && \
	rm -rf /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Install bazel.
RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list && \
	curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
RUN apt-get update && apt-get install -y bazel

# Install tensorflow dependencies.
RUN apt-get install -y python3-numpy python3-dev python3-pip python3-wheel libcupti-dev locate

RUN mkdir ~/git && cd ~/git && git clone https://github.com/tensorflow/tensorflow && cd tensorflow && git checkout v1.2.1

RUN mkdir /docker

# "locate" needs updatedb
RUN updatedb

# ./configure
COPY ./docker/configure_tensorflow.sh /docker/configure_tensorflow.sh
RUN cd ~/git/tensorflow && bash /docker/configure_tensorflow.sh

# build
RUN cd ~/git/tensorflow && bazel build --config=opt --config=cuda //tensorflow:libtensorflow_cc.so
RUN cd ~/git/tensorflow && bazel build --config=opt --config=cuda //tensorflow/tools/pip_package:build_pip_package

# install
COPY ./docker/install_tensorflow.sh /docker/install_tensorflow.sh
RUN cd ~/git/tensorflow && bash /docker/install_tensorflow.sh

# Install opencv
RUN apt-get install -y libopencv-dev

# Install gflags, gtest, glog
RUN apt-get install -y libgflags-dev libgtest-dev libgoogle-glog-dev
#https://askubuntu.com/questions/145887/why-no-library-files-installed-for-google-test
RUN cd /usr/src/gtest && cmake . && make -j4 && mv libg* /usr/lib/

#Install other dependencies
RUN apt-get install -y libblosc-dev libsqlite3-dev libassimp-dev assimp-utils libboost-all-dev libglm-dev
