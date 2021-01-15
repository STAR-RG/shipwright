FROM ubuntu:14.04

ENV SCALA_VERSION=2.10.4
ENV SPARK_VERSION=1.4.1

EXPOSE 80 4042 9160 9042 9200 7077 38080 38081 6060 6061 8090 8099 10000 50070 50090 9092 6066 9000 19999 6379 6081 7474 8787 5601 8989 7979 4040

RUN \
 apt-get update \
 && apt-get install -y curl \
 && apt-get install -y wget \
 && apt-get install -y vim \
 && apt-get install -y unzip \
 && apt-get install -y screen \

# Start in Home Dir (/root)
 && cd ~ \

# Git
 && apt-get install -y git \

# SSH
 && apt-get install -y openssh-server \

# Java
 && apt-get install -y default-jdk

 RUN \
 cd /root \
 && wget https://s3.eu-central-1.amazonaws.com/spark-notebook/traning/apache-cassandra-2.2.0-bin.tar.gz \
 && tar xvzf apache-cassandra-2.2.0-bin.tar.gz \
 && rm apache-cassandra-2.2.0-bin.tar.gz

# Apache Kafka (Confluent Distribution)
RUN \
 cd /root \
 && wget https://s3.eu-central-1.amazonaws.com/spark-notebook/traning/confluent-1.0-2.10.4.tar.gz \
 && tar xvzf confluent-1.0-2.10.4.tar.gz \
 && rm confluent-1.0-2.10.4.tar.gz

# SBT

ADD https://dl.bintray.com/sbt/native-packages/sbt/0.13.8/sbt-0.13.8.tgz /root/

RUN \
 cd /root/ \
 && tar xvzf sbt-0.13.8.tgz \
 && rm sbt-0.13.8.tgz


# Spark Notebook: 0.6.3 default scala 2.11 spark 1.6.0 hadoop 2.2.0 + hive + parquet, guava 16.0.1 for cassandra connector
RUN \
 cd /root \
 && wget https://s3-us-west-1.amazonaws.com/data-fellas-spark-deep-learning/spark-notebook-0.6.3-scala-2.11.7-spark-1.6.0-hadoop-2.2.0-with-hive-with-parquet.tgz \
 && tar xvzf spark-notebook-*tgz --warning=no-timestamp \
 && rm spark-notebook-*tgz \
 && mv spark-notebook-* spark-notebook

# Have a directory to mount data directory on host
RUN \
 cd /root \
 mkdir data

RUN mkdir -p /root/spark-deep-learning

ADD scripts/* /root/spark-deep-learning/
ADD config /root/spark-deep-learning/config

ADD notebooks /root/spark-notebook/notebooks/
ADD data /root/data

WORKDIR /root/spark-deep-learning
