
FROM debian:latest

MAINTAINER Contextual Dynamics Lab <contextualdynamics@gmail.com>

RUN apt-get update && apt-get install -y eatmydata
RUN eatmydata apt-get install -y wget bzip2 ca-certificates \
    git \
    swig \
    mpich \
    pkg-config \
    gcc \
    wget \
    curl \
    vim \
    nano

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda3-5.3.1-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh
ENV PATH /opt/conda/bin:$PATH

RUN conda install pystan -y
RUN pip install --upgrade pip
RUN pip install hypertools
RUN conda update numpy scipy pandas scikit-learn seaborn matplotlib


RUN pip install pytest \
ipytest

ADD PANDAS /PANDAS
ADD coding /coding
ADD docker /docker
ADD testing /testing
ADD tutorial_template /tutorial_template
ADD STAN /STAN
# ENV GOOGLE_APPLICATION_CREDENTIALS=/data/credentials.json

EXPOSE 9999