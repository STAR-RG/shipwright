FROM quay.io/ukhomeofficedigital/centos-base:latest

RUN yum update -y && \
  yum install -y java-headless tar wget && \
  yum clean all

EXPOSE 2181 2888 3888

ENV ZK_VERSION 3.4.13
RUN wget -q http://mirror.ox.ac.uk/sites/rsync.apache.org/zookeeper/zookeeper-${ZK_VERSION}/zookeeper-${ZK_VERSION}.tar.gz -O - | tar -xzf -; mv zookeeper-${ZK_VERSION} /zookeeper


USER 1000
VOLUME /data
WORKDIR /zookeeper
COPY zoo.cfg /zookeeper/conf/zoo.cfg
COPY run.sh /run.sh

CMD /run.sh
