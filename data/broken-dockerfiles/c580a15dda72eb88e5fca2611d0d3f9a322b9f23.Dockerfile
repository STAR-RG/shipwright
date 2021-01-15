FROM centos:7
MAINTAINER Pavlina Bortlova <pbortlov@redhat.com>

LABEL description="Review-rot - gather information about opened merge or pull requests"
LABEL summary="review-rot git gitlab github pagure gerrit"
LABEL vendor="PnT DevOps Automation - Red Hat, Inc."

USER root

RUN yum install -y epel-release && yum update -y && \
    yum install -y git gcc python-devel \
    python-setuptools python-pip libyaml-devel && \
    yum clean all

# copy workdir for installation of review-rot
WORKDIR /reviewrot
ADD . /reviewrot

# install review-rot
RUN pip install --upgrade pip setuptools && python setup.py install

# create direcory for the run of review-rot,
# set privileges and env variable
RUN mkdir -p /.cache/Python-Eggs && chmod g+rw /.cache/Python-Eggs
ENV PYTHON_EGG_CACHE=/.cache/Python-Eggs
