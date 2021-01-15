# This file creates a container that runs X11 and SSH services
# The ssh is used to forward X11 and provide you encrypted data
# communication between the docker container and your local 
# machine.
#
# Xpra allows to display the programs running inside of the
# container such as Firefox, LibreOffice, xterm, etc. 
# with disconnection and reconnection capabilities
#
# The applications are rootless, therefore the client machine 
# manages the windows displayed.
# 
# ROX-Filer creates a very minimalist way to manage 
# files and icons on the desktop. 
#
# Author: Roberto Gandolfo Hashioka
# Date: 07/10/2013


FROM ubuntu:12.10
MAINTAINER Roberto G. Hashioka "roberto_hashioka@hotmail.com"

RUN echo "deb http://mirrors.sohu.com/ubuntu/ quantal main restricted universe multiverse" > /etc/apt/sources.list
RUN echo "deb http://mirrors.sohu.com/ubuntu/ quantal-security main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.sohu.com/ubuntu/ quantal-updates main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.sohu.com/ubuntu/ quantal-proposed main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb http://mirrors.sohu.com/ubuntu/ quantal-backports main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.sohu.com/ubuntu/ quantal main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.sohu.com/ubuntu/ quantal-security main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.sohu.com/ubuntu/ quantal-updates main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.sohu.com/ubuntu/ quantal-proposed main restricted universe multiverse" >> /etc/apt/sources.list
RUN echo "deb-src http://mirrors.sohu.com/ubuntu/ quantal-backports main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Installing the environment required: xserver, xdm, flux box, roc-filer and ssh
RUN apt-get install -y xpra rox-filer ssh pwgen

# Upstart and DBus have issues inside docker. We work around in order to install firefox.
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl

# Installing fuse package (libreoffice-java dependency) and it's going to try to create
# a fuse device without success, due the container permissions. || : help us to ignore it. 
# Then we are going to delete the postinst fuse file and try to install it again!
# Thanks Jerome for helping me with this workaround solution! :)
# Now we are able to install the libreoffice-java package  
RUN apt-get -y install fuse  || :
RUN rm -rf /var/lib/dpkg/info/fuse.postinst
RUN apt-get -y install fuse

# Installing the apps: Firefox, flash player plugin, LibreOffice and xterm
# libreoffice-base installs libreoffice-java mentioned before
RUN apt-get install -y libreoffice-base firefox libreoffice-gtk libreoffice-calc xterm ubuntu-restricted-extras 

# Set locale (fix the locale warnings)
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :

# Copy the files into the container
ADD . /src

EXPOSE 22
# Start xdm and ssh services.
CMD ["/bin/bash", "/src/startup.sh"]
