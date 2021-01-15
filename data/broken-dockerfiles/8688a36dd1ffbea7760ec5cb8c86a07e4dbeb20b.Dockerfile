# Android development environment for ubuntu precise (12.04 LTS).
# version 0.0.1

# Start with ubuntu precise (LTS).
FROM ubuntu:12.04

MAINTAINER ahazem <ahazemm@gmail.com>

# Never ask for confirmations
ENV DEBIAN_FRONTEND noninteractive
RUN echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections

# Update apt
RUN apt-get update

# First, install add-apt-repository and bzip2
RUN apt-get -y install python-software-properties bzip2

# Add oracle-jdk6 to repositories
RUN add-apt-repository ppa:webupd8team/java

# Make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

# Update apt
RUN apt-get update

# Install oracle-jdk6
RUN apt-get -y install oracle-java6-installer

# Fake a fuse install (to prevent ia32-libs-multiarch package from producing errors)
RUN apt-get install libfuse2
RUN cd /tmp ; apt-get download fuse
RUN cd /tmp ; dpkg-deb -x fuse_* .
RUN cd /tmp ; dpkg-deb -e fuse_*
RUN cd /tmp ; rm fuse_*.deb
RUN cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst
RUN cd /tmp ; dpkg-deb -b . /fuse.deb
RUN cd /tmp ; dpkg -i /fuse.deb

# Install support libraries for 32-bit
RUN apt-get -y install ia32-libs-multiarch

# Install android sdk
RUN wget http://dl.google.com/android/android-sdk_r22.3-linux.tgz
RUN tar -xvzf android-sdk_r22.3-linux.tgz
RUN mv android-sdk-linux /usr/local/android-sdk

# Install android ndk
RUN wget http://dl.google.com/android/ndk/android-ndk-r9c-linux-x86_64.tar.bz2
RUN tar -xvjf android-ndk-r9c-linux-x86_64.tar.bz2
RUN mv android-ndk-r9c /usr/local/android-ndk

# Install apache ant
RUN wget http://archive.apache.org/dist/ant/binaries/apache-ant-1.8.4-bin.tar.gz
RUN tar -xvzf apache-ant-1.8.4-bin.tar.gz
RUN mv apache-ant-1.8.4 /usr/local/apache-ant

# Add android tools and platform tools to PATH
ENV ANDROID_HOME /usr/local/android-sdk
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools
ENV PATH $PATH:$ANDROID_HOME/build-tools/19.0.1

# Add ant to PATH
ENV ANT_HOME /usr/local/apache-ant
ENV PATH $PATH:$ANT_HOME/bin

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-6-oracle

# Remove compressed files.
RUN cd /; rm android-sdk_r22.3-linux.tgz && rm android-ndk-r9c-linux-x86_64.tar.bz2 && rm apache-ant-1.8.4-bin.tar.gz

# Install latest android (19 / 4.4.2) tools and system image.
RUN echo "y" | android update sdk --no-ui --force --filter platform-tools,android-19,build-tools-19.0.1,sysimg-19
