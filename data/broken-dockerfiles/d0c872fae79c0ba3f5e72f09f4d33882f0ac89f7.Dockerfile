FROM debian:latest

MAINTAINER Atilim Cetin <atilim.cetin@gmail.com>


RUN apt-get update && \
    apt-get install -y git gcc g++ gdb libboost-all-dev libopenexr-dev make cmake flex bison zlib1g-dev llvm-dev libclang-dev clang libtiff5-dev libpng12-dev wget lua5.1 liblua5.1-0-dev && \
    cd ~ && \
    wget https://github.com/OpenImageIO/oiio/archive/Release-1.7.9.tar.gz && \
    wget https://github.com/imageworks/OpenShadingLanguage/archive/Release-1.7.5.tar.gz && \
    wget https://github.com/embree/embree/releases/download/v2.13.0/embree-2.13.0.x86_64.linux.tar.gz && \
    cd ~ && \
    tar zxvf Release-1.7.9.tar.gz && \
    cd oiio-Release-1.7.9/ && \
    make && \
    export OPENIMAGEIOHOME=/root/oiio-Release-1.7.9/dist/linux64/ && \
    export LD_LIBRARY_PATH=/root/oiio-Release-1.7.9/dist/linux64/lib/ && \
    cd ~ && \
    tar zxvf Release-1.7.5.tar.gz && \
    cd OpenShadingLanguage-Release-1.7.5/ && \
    export USE_CPP11=1 && \
    make && \
    cd ~ && \
    tar zxvf embree-2.13.0.x86_64.linux.tar.gz && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

