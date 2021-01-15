FROM ubuntu:16.04

RUN apt-get update && apt-get upgrade
RUN apt-get install -y python3-pip python3-crypto libsnappy-dev
RUN apt-get install -y zip

RUN mkdir -p /syncrypt
ADD ./syncrypt /syncrypt/syncrypt
ADD ./scripts /syncrypt/scripts
ADD ./dist-files /syncrypt/dist-files
ADD ./setup.cfg /syncrypt/
ADD ./setup.py /syncrypt/
ADD ./README.md /syncrypt/

RUN pip3 install -e '/syncrypt[dist]'

WORKDIR /syncrypt

ADD ./syncrypt.spec /syncrypt/syncrypt.spec
RUN mkdir -p /syncrypt/dist
VOLUME /syncrypt/dist

CMD python3 setup.py dist

