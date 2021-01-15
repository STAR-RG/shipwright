FROM ubuntu:15.04

ENV CUDA_GCC_VER 4.9

ENV CUDA_VER1 7
ENV CUDA_VER2 5
ENV CUDA_VER3 18

ENV DRIVER_VER 361.28


RUN apt-get -y update \
    && apt-get -y install \
         gcc-${CUDA_GCC_VER} g++-${CUDA_GCC_VER} libssl-dev bc wget \ 
         curl git make dpkg-dev module-init-tools \
    && mkdir -p /usr/src/kernels \
    && mkdir -p /opt/nvidia \
    && apt-get autoremove && apt-get clean

# Ensure we're using gcc version GCC_VER
RUN update-alternatives --install \
            /usr/bin/gcc gcc /usr/bin/gcc-${CUDA_GCC_VER} 60 \
            --slave \
            /usr/bin/g++ g++ /usr/bin/g++-${CUDA_GCC_VER}

#print gcc ver to check
RUN update-alternatives --config gcc


# Download CUDA & Drivers

RUN mkdir -p /opt/nvidia

RUN curl http://developer.download.nvidia.com/compute/cuda/${CUDA_VER1}.${CUDA_VER2}/Prod/local_installers/cuda_${CUDA_VER1}.${CUDA_VER2}.${CUDA_VER3}_linux.run > /opt/nvidia/cuda.run

RUN curl  http://us.download.nvidia.com/XFree86/Linux-x86_64/${DRIVER_VER}/NVIDIA-Linux-x86_64-${DRIVER_VER}.run > /opt/nvidia/driver.run


# Download Linux Kernel Source

RUN mkdir -p /usr/src/kernels
WORKDIR /usr/src/kernels

RUN curl https://www.kernel.org/pub/linux/kernel/v`uname -r | grep -o '^[0-9]'`.x/linux-`uname -r | grep -o '[0-9].[0-9].[0-9]'`.tar.xz > linux.tar.xz \
    && mkdir linux \
    && tar -xvf linux.tar.xz -C linux --strip-components=1

WORKDIR /usr/src/kernels/linux
RUN zcat /proc/config.gz > .config \
    && make modules_prepare \
    && echo "#define UTS_RELEASE \"$(uname -r)\"" > include/generated/utsrelease.h

WORKDIR /opt/nvidia

ENV CUDATOOLKIT_HOME /opt/nvidia/cudatoolkit
ENV CUDASAMPLES_HOME /opt/nvidia/samples
ENV NVIDIA_DOCKER_PATH /opt/nvidia-docker

RUN chmod +x ./cuda.run \
 && chmod +x ./driver.run \
 && mkdir -p $NVIDIA_DOCKER_PATH/bin \
 && mkdir -p $NVIDIA_DOCKER_PATH/lib64 \
 && echo "#!/bin/sh -x" > install.sh \
 && echo "./driver.run --silent --kernel-source-path=/usr/src/kernels/linux" >> install.sh \
 && echo "modprobe nvidia" >> install.sh \
 && echo "mkdir -p /opt/nvidia/cudatoolkit" >> install.sh \
 && echo "mkdir -p /opt/nvidia/samples" >> install.sh \
 && echo "./cuda.run --silent --toolkit --toolkitpath=${CUDATOOLKIT_HOME} --samples --samplespath=${CUDASAMPLES_HOME}" >> install.sh \
 && echo "cd ${CUDASAMPLES_HOME}/NVIDIA_CUDA-${CUDA_VER1}.${CUDA_VER2}_Samples/1_Utilities/deviceQuery && make && ./deviceQuery" >> install.sh \
 && echo "export PATH=$PATH:${NVIDIA_DOCKER_PATH}/bin" >> install.sh \
 && echo "nvidia-docker volume setup" >> install.sh \
 && echo "cp /usr/lib/x86_64-linux-gnu/libcuda.so.${DRIVER_VER} ${NVIDIA_DOCKER_PATH}/lib64" >> install.sh \
 && echo "cp /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.${DRIVER_VER} ${NVIDIA_DOCKER_PATH}/lib64" >> install.sh \
 && echo "cd ${NVIDIA_DOCKER_PATH}/lib64" >> install.sh \
 && echo "ln -s libcuda.so.${DRIVER_VER} libcuda.so.1" >> install.sh \
 && echo "ln -s libnvidia-ml.so.${DRIVER_VER} libnvidia-ml.so.1" >> install.sh \
 && chmod +x ./install.sh

CMD ./install.sh


