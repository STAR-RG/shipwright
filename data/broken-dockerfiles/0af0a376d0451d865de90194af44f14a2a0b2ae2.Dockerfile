FROM ubuntu:15.10
MAINTAINER manuel.bessler@gmail.com
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get install -y libc6:i386
RUN apt-get install -y --no-install-recommends libgtk-3-0:i386 libgtk-3-common:i386 adwaita-icon-theme
RUN apt-get install -y firefox:i386
RUN apt-get install -y openjdk-7-jre:i386 icedtea-7-plugin:i386 libxmu6:i386
RUN rm -rf /var/lib/apt/lists/*
ENV HOME=/webex
#ENTRYPOINT [ "/usr/bin/firefox", "--profile", "/webex/profile", "-no-remote", "--new-instance" ]
ENTRYPOINT [ "/usr/bin/firefox", "-no-remote", "--new-instance" ]
CMD http://www.webex.com
