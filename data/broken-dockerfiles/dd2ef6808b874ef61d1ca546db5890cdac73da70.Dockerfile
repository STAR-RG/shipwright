FROM ubuntu:14.04
MAINTAINER Yohana Khoury yohana@yohanakhoury.com
ENV DEBIAN_FRONTEND noninteractive


RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install nano wget openssh-server -y && \
    apt-get install libgtk2.0-0:i386 libpangoxft-1.0-0:i386 libpangox-1.0-0:i386 libxmu6:i386 libxtst6:i386 libdbus-glib-1-2:i386 -y && \
    apt-get install lib32stdc++6 libasound2 -y && \
    apt-get install -y libpulse0:i386 pulseaudio:i386 && \
    localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || true && \
    echo root:root | chpasswd &&\
    mkdir /root/.ssh && \
    mkdir /var/run/sshd && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'X11UseLocalhost no' >> /etc/ssh/sshd_config

RUN apt-get install -y pulseaudio && echo enable-shm=no >> /etc/pulse/client.conf

COPY resources /root/resources/
COPY install.sh /root/install.sh
RUN /bin/bash /root/install.sh

ENTRYPOINT ["/usr/sbin/sshd",  "-D"]
EXPOSE 22
