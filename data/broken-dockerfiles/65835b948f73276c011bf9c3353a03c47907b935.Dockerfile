FROM nvidia/cuda:latest

ENV USER root

# -------------------------------------------------------------------------------------
# install needed software -
# openssh
# mpi
# awscli
# supervisor
# -------------------------------------------------------------------------------------

RUN apt update
RUN apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt install -y iproute2 openssh-server openssh-client python python-pip python3 python3-dev python3-pip build-essential gfortran wget curl libfftw3-dev git libcudnn7 libcudnn7-dev wget libjemalloc-dev pkg-config zip unzip

RUN pip2 install supervisor awscli

ENV DEBIAN_FRONTEND noninteractive

ENV NOTVISIBLE "in users profile"

#####################################################
## SSH SETUP
RUN mkdir -p /var/run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN echo "export VISIBLE=now" >> /etc/profile

RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
ENV SSHDIR /root/.ssh
RUN mkdir -p ${SSHDIR}
RUN touch ${SSHDIR}/sshd_config
RUN ssh-keygen -t rsa -f ${SSHDIR}/ssh_host_rsa_key -N ''
RUN cp ${SSHDIR}/ssh_host_rsa_key.pub ${SSHDIR}/authorized_keys
RUN cp ${SSHDIR}/ssh_host_rsa_key ${SSHDIR}/id_rsa
RUN echo "    IdentityFile ${SSHDIR}/id_rsa" >> /etc/ssh/ssh_config
RUN echo "Host *" >> /etc/ssh/ssh_config && echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config
RUN chmod -R 600 ${SSHDIR}/* && \
    chown -R ${USER}:${USER} ${SSHDIR}/
# check if ssh agent is running or not, if not, run
RUN eval `ssh-agent -s` && ssh-add ${SSHDIR}/id_rsa

##################################################
## S3 OPTIMIZATION

RUN aws configure set default.s3.max_concurrent_requests 30
RUN aws configure set default.s3.max_queue_size 10000
RUN aws configure set default.s3.multipart_threshold 64MB
RUN aws configure set default.s3.multipart_chunksize 16MB
RUN aws configure set default.s3.max_bandwidth 4096MB/s
RUN aws configure set default.s3.addressing_style path

##################################################
## CUDA MPI

RUN wget -O /tmp/openmpi.tar.gz https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.0.tar.gz && \
    tar -xvf /tmp/openmpi.tar.gz -C /tmp
RUN cd /tmp/openmpi* && ./configure --prefix=/opt/openmpi --with-cuda --enable-mpirun-prefix-by-default && \
    make -j $(nproc) && make install
RUN echo "export PATH=$PATH:/opt/openmpi/bin" >> /etc/bash.bashrc
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/openmpi/lib:/usr/local/cuda/include:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64" >> /etc/bash.bashrc

###################################################
## TENSORFLOW INSTALL

RUN pip3 install numpy six wheel mock
RUN pip3 install keras_applications==1.0.6 --no-deps
RUN pip3 install keras_preprocessing==1.0.5 --no-deps

RUN mkdir -p /usr/lib/x86_64-linux-gnu/nccl/lib
RUN mkdir -p /usr/lib/x86_64-linux-gnu/nccl/include
RUN cp /usr/lib/x86_64-linux-gnu/libnccl* /usr/lib/x86_64-linux-gnu/nccl/
RUN cp /usr/include/nccl.h /usr/lib/x86_64-linux-gnu/nccl/include

RUN wget -O /tmp/bazel.sh "https://github.com/bazelbuild/bazel/releases/download/0.18.0/bazel-0.18.0-installer-linux-x86_64.sh"
RUN chmod +x /tmp/bazel.sh
RUN bash -c "/tmp/bazel.sh"
RUN git clone https://github.com/tensorflow/tensorflow /root/tensorflow
ADD conf/tensorflow_build.sh /root/
RUN chmod +x /root/tensorflow_build.sh
RUN /root/tensorflow_build.sh

ADD conf/horovod_build.sh /root/
RUN chmod +x /root/horovod_build.sh
RUN /root/horovod_build.sh

###################################################
## IMAGENET DATASET

RUN git clone https://github.com/aws-samples/deep-learning-models.git /root/deep-learning-models

 
###################################################
## supervisor container startup

ADD conf/supervisord/supervisord.conf /etc/supervisor/supervisord.conf
ADD supervised-scripts/mpi-run.sh supervised-scripts/mpi-run.sh
RUN chmod 755 supervised-scripts/mpi-run.sh

EXPOSE 22
RUN export PATH="$PATH:/opt/openmpi/bin"
ADD batch-runtime-scripts/entry-point.sh batch-runtime-scripts/entry-point.sh
RUN chmod 0755 batch-runtime-scripts/entry-point.sh

CMD /batch-runtime-scripts/entry-point.sh
