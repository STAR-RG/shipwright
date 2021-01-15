FROM ubuntu:xenial

MAINTAINER http://ydk.io

COPY . /root/ydk-gen

RUN echo 'Installing dependencies'

WORKDIR /root/ydk-gen

RUN /bin/bash -c './test/dependencies_ubuntu.sh && ./test/dependencies_linux_gnmi.sh'

RUN ./generate.py -i --cpp --core
RUN ./generate.py -i --cpp --service profiles/services/gnmi-0.4.0_post2.json

RUN pip  install -r requirements.txt
RUN pip3 install -r requirements.txt

RUN python  generate.py -i --core
RUN python3 generate.py -i --core

RUN python  generate.py -i --service profiles/services/gnmi-0.4.0.json
RUN python3 generate.py -i --service profiles/services/gnmi-0.4.0.json
