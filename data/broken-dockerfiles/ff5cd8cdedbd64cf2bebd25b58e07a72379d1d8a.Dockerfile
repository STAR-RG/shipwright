FROM ubuntu:15.04
MAINTAINER Joshua Kolden <joshua@studiopyxis.com>

# Setup environment
RUN apt-get -y update && apt-get -y install gcc-4.8 \
    wget git make dpkg-dev module-init-tools && \
    mkdir -p /usr/src/kernels && \
    mkdir -p /opt/nvidia && \
    apt-get autoremove && apt-get clean

# Ensure we're using gcc 4.8
RUN update-alternatives --install  /usr/bin/gcc gcc /usr/bin/gcc-4.8 10

# Downloading early so we fail early if we can't get the key ingredient
RUN wget -P /opt/nvidia http://us.download.nvidia.com/XFree86/Linux-x86_64/352.21/NVIDIA-Linux-x86_64-352.21.run

# Download kernel source and prepare modules
WORKDIR /usr/src/kernels
RUN git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git linux
WORKDIR linux
RUN git checkout -b stable v`uname -r` && zcat /proc/config.gz > .config && make modules_prepare
RUN sed -i -e "s/`uname -r`+/`uname -r`/" include/generated/utsrelease.h # In case a '+' was added

# Nvidia drivers setup
WORKDIR /opt/nvidia
RUN echo "./NVIDIA-Linux-x86_64-352.21.run -q -a -n -s --kernel-source-path=/usr/src/kernels/linux/ && modprobe nvidia" >> install_kernel_module && \
    chmod +x NVIDIA-Linux-x86_64-352.21.run install_kernel_module

CMD ["/opt/nvidia/install_kernel_module"]
