FROM tensorflow/tensorflow:1.8.0-py3

MAINTAINER Olav Nymoen (olav@olavnymoen.com)

ADD . /usr/local/tfweb/

WORKDIR /usr/local/tfweb

RUN python setup.py install

ENTRYPOINT ["tfweb"]

EXPOSE 8080
