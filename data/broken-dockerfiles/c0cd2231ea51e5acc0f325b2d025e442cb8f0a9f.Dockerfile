#This Dockerfiel uses the debian iamge
#VERSION 1 - EDITION 1
#Author: Rokas_Urbelis
FROM debian:latest
MAINTAINER crack Docker maintainers "blog.linux-code.com"
ENV CRACK_VERSION 1.0
###update source
ENV SCPATH /etc/apt/sources.list
RUN echo 'deb http://mirrors.ustc.edu.cn/debian stable main contrib non-free' > $SCPATH &&\
    echo 'deb-src http://mirrors.ustc.edu.cn/debian stable main contrib non-free' >> $SCPATH &&\ 
    echo 'deb http://mirrors.ustc.edu.cn/debian stable-proposed-updates main contrib non-free' >>$SCPATH &&\
    echo 'deb-src http://mirrors.ustc.edu.cn/debian stable-proposed-updates main contrib non-free' >>$SCPATH 
RUN apt-get update
RUN apt-get install git wget curl -y
RUN git clone https://github.com/RokasUrbelis/system_safety_test.git
ENV CRACKPATH /system_safety_test
RUN chmod +x $CRACKPATH/crack.sh
ENV PATH $CRACKPATH:/usr/local/bin:/usr/bin/:/usr/sbin:/sbin:/bin
WORKDIR $CRACKPATH
CMD crack.sh
