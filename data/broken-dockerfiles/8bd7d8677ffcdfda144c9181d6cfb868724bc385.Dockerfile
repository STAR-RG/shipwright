############################################################
# Dockerfile to run Traitar - the microbial trait analyzer 
# Based on Ubuntu Image
############################################################

# Set the base image to use to Ubuntu
FROM ubuntu:trusty 

RUN apt-get update
MAINTAINER Aaron Weimann (weimann@hhu.de)
RUN sudo apt-get install -y python-scipy python-matplotlib python-pip python-pandas
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse ">> /etc/apt/sources.list 
RUN sudo apt-get update
RUN sudo apt-get install -y hmmer prodigal
RUN sudo apt-get install -y wget 
RUN sudo apt-get install -y git
RUN mkdir /home/traitar
RUN wget -O /home/traitar/Pfam-A.hmm.gz ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam27.0/Pfam-A.hmm.gz
RUN gunzip /home/traitar/Pfam-A.hmm.gz 
RUN sudo apt-get install -y parallel 
ENV shell /bin/bash
WORKDIR  /home/traitar
ADD https://www.random.org/strings/?num=16&len=16&digits=on&upperalpha=on&loweralpha=on&unique=on&format=plain&rnd=new uuid
RUN git clone https://github.com/aweimann/traitar
WORKDIR  /home/traitar/traitar
RUN python setup.py sdist
RUN pip install traitar  --find-links file:///home/traitar/traitar/dist
RUN traitar pfam --local /home/traitar
