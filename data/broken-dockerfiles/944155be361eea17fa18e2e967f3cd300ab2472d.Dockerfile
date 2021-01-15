FROM quay.io/ukhomeofficedigital/centos-base:latest

RUN yum update -y && \
  yum install -y java-headless tar wget &&\
  yum clean all

EXPOSE 9092

ENV KAFKA_VERSION 1.1.1
ENV SCALA_VERSION 2.12
RUN wget -q http://mirror.vorboss.net/apache/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -O - | tar -xzf -; mv kafka_${SCALA_VERSION}-${KAFKA_VERSION} /kafka

RUN useradd -ms /bin/bash -u 1000 centos
USER 1000
VOLUME /data
WORKDIR /kafka
COPY config/server.properties /kafka/config/server.properties
COPY run.sh /run.sh

CMD /run.sh