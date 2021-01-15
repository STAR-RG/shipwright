FROM nvidia/cuda:latest

# packaging dependencies
RUN apt update -y && apt install git-core wget -y
RUN git clone https://github.com/gpue-group/gpue /gpue && \
    wget https://cmake.org/files/v3.13/cmake-3.13.0-rc2-Linux-x86_64.sh && \
    chmod +x ./cmake-3.13.0-rc2-Linux-x86_64.sh && \
    ./cmake-3.13.0-rc2-Linux-x86_64.sh --skip-license --prefix=/usr/local

RUN cd /gpue && cmake . && make

#The Docker image that is built with the above commands can be run as follows:
#    (sudo) docker run --runtime=nvidia --rm <IMAGE TAG> /gpue/gpue -u
# It is assumed the the Nvidia docker runtime has been installed, following 
# the instructins provided here: https://github.com/NVIDIA/nvidia-docker


