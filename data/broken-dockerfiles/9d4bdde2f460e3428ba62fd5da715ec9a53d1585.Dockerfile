#Dockerfile

FROM index.alauda.cn/tutum/centos:centos6
MAINTAINER hanxi <hanxi.info@gmail.com>

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

EXPOSE 8000
EXPOSE 80
EXPOSE 22

RUN yum install -y git unzip
RUN curl -LOR http://git.oschina.net/hanxi/md-pages/raw/master/md-pages.zip
RUN unzip md-pages.zip

WORKDIR /md-pages
RUN mkdir -p /md-pages/http-file-server/files/md

#CMD ["/bin/bash", "/md-pages/start.sh"]

#End
