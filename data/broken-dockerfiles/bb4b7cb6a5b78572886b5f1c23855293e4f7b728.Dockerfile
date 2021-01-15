#Base image of Ubuntu 12.04 (precise) 64-bit with git and go compiler installed

#Version 0.1

FROM ubuntu
MAINTAINER Piotr Chudzik "piotrchudzik89@gmail.com"

#Check that the package repository is up to date

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

RUN apt-get update

#Install git and wget

RUN apt-get install -y git wget vim openssh-server

#Install Go
#Get the installer (please update in the future if needed)

#RUN wget https://go.googlecode.com/files/go1.1.2.linux-amd64.tar.gz

#Extract the archive
#RUN tar -C /usr/local -xzf go1.1.2.linux-amd64.tar.gz

#Add go/bin to the path
#RUN export PATH=$PATH:/usr/local/go/bin

