FROM ubuntu:trusty

MAINTAINER Prabeesh K.

RUN \
    apt-get -y update &&\
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" > /etc/apt/sources.list.d/webupd8team-java.list &&\
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/apt/sources.list.d/webupd8team-java.list &&\
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 &&\
    apt-get -y update &&\
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections &&\
    apt-get install -y oracle-java7-installer &&\
    apt-get install -y curl

ENV SPARK_VERSION 1.4.0
ENV SPARK_HOME /usr/local/src/spark-$SPARK_VERSION

RUN \
    mkdir -p $SPARK_HOME &&\
    curl -s http://d3kbcqa49mib13.cloudfront.net/spark-$SPARK_VERSION.tgz | tar -xz -C $SPARK_HOME --strip-components=1 &&\
    cd $SPARK_HOME &&\
    build/mvn -DskipTests clean package

ENV PYTHONPATH $SPARK_HOME/python/:$PYTHONPATH

RUN apt-get install -y build-essential \
    python \
    python-dev \
    python-pip \
    python-zmq

RUN pip install py4j \
    ipython[notebook]==3.2 \
    jsonschema \
    jinja2 \
    terminado \
    tornado

RUN ipython profile create pyspark

COPY pyspark-notebook.py /root/.ipython/profile_pyspark/startup/pyspark-notebook.py

VOLUME /notebook
WORKDIR /notebook

EXPOSE 8888

CMD ipython notebook --no-browser --profile=pyspark --ip=*
