# hanLP-python
#
#
# Version: 0.2.1

FROM java:8

MAINTAINER Tid at tid@breaktime.com.tw

RUN apt-get update \
    && apt-get install apt-utils g++ python2.7 python-dev python-pip python-mock -y \
    && pip install flask \
    && pip install flask_restful \
    && pip install pyyaml

RUN cd ~/ \
    && wget https://pypi.python.org/packages/d2/c2/cda0e4ae97037ace419704b4ebb7584ed73ef420137ff2b79c64e1682c43/JPype1-0.6.2.tar.gz \
    && tar -xvzf JPype1-0.6.2.tar.gz \
    && cd JPype1-0.6.2 \
    && python setup.py install \
    && cd ~ \
    && rm JPype1-0.6.2.tar.gz \
    && rm -r JPype1-0.6.2

RUN cd / \
    && mkdir hanlp

COPY . /hanlp

WORKDIR /hanlp