# VERSION:      1.0
# DESCRIPTION:  Create The Foundry's Nuke container with it's dependencies
# AUTHOR:       Timon Relitzki <timonrelitzki@gmail.com>
# COMMENTS:
#   This Dockerfile sets up a complete The Foundry's Nuke Installation with native X11
#   unix socket.
#   Tested on Fedora 19 and CentOS 6.6
# USAGE:
#   # Download Nuke Dockerfile
#   wget http://raw.githubusercontent.com/remisdemis/docker-nuke/master/Dockerfile
#   # Set the ENV's NK_VERSION, NK_MAJOR_VERSION and NV_VERSION according to match
#   # the version you wan't to build.
#   # On line 45 setup where your Nuke Installer Download is located.
#   # Build Nuke image
#   docker build -t nuke .
#   # Run GUI enabled Nuke in the Container
#   docker run -it -v /tmp/.X11-unix:/tmp/.X11-unix \
#       -e DISPLAY=unix$DISPLAY
#       -v /dev/nvidia0:/dev/nvidia0 \
#       -v /dev/nvidiactl:/dev/nvidiactl \
#       --privileged nuke

# Base Docker Image.
FROM centos:6.6
MAINTAINER Timon Relitzki <timonrelitzki@gmail.com>

# Update the Base Image and install all prerequisites.
RUN yum -y update && \
    yum -y groupinstall "X Window System" "Fonts" && \
    yum -y install wget unzip mesa-libGLU alsa-lib libpng12 SDL

# Set the Nuke and NVIDIA Version as ENV.
ENV NK_VERSION 9.0v4
ENV NK_MAJOR_RELEASE 9.0
ENV NV_VERSION 331.20

# Install NVIDIA Drivers.
RUN wget -P /tmp/ \
    http://us.download.nvidia.com/XFree86/Linux-x86_64/$NV_VERSION/NVIDIA-Linux-x86_64-$NV_VERSION.run && \
    sh /tmp/NVIDIA-Linux-x86_64-$NV_VERSION.run -a -N --ui=none --no-kernel-module
# Cleanup the NVIDIA Installer.
RUN rm -f /tmp/NVIDIA-Linux-x86_64-$NV_VERSION.run

# Install Nuke itself.
RUN wget -P /tmp/ \
    http://thefoundry.*.com/products/nuke/releases/$NK_VERSION/Nuke$NK_VERSION-linux-x86-release-64.tgz && \
    tar xvzf /tmp/Nuke$NK_VERSION-linux-x86-release-64.tgz -C /tmp
# Cleanup the .tgz File.
RUN rm -f /tmp/Nuke$NK_VERSION-linux-x86-release-64.tgz

RUN unzip /tmp/Nuke$NK_VERSION-linux-x86-release-64-installer -d Nuke$NK_VERSION
# Cleanup the Nuke Installer.
RUN rm -f /tmp/Nuke$NK_VERSION-linux-x86-release-64-installer

# Create a User and switch to it. Nuke does not work well under root User.
RUN groupadd -r nuke && \
    useradd -r -g nuke nuke
USER nuke

# Mount Volumes.


# Set additional ENV's specially for Nuke
ENV FOUNDRY_LICENSE_FILE /usr/local/foundry/FLEXlm
ENV NUKE_DISK_CACHE /tmp/nuke

ENTRYPOINT Nuke$NK_VERSION/Nuke$NK_MAJOR_RELEASE
# Entry Flags.
CMD ["--ple", "-V2"]
