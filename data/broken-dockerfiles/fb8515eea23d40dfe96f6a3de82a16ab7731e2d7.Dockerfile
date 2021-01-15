FROM java:openjdk-8-jdk
MAINTAINER tobilg <fb.tools.github@gmail.com>

# Environment variables
ENV PIO_VERSION 0.9.6
ENV SPARK_VERSION 1.6.1
ENV ELASTICSEARCH_VERSION 1.7.5
ENV HBASE_VERSION 1.0.3

# Base paths
ENV PIO_HOME /PredictionIO-${PIO_VERSION}
ENV PATH=${PIO_HOME}/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Install other dependencies
RUN apt-get update && \
    apt-get install -y curl libgfortran3 python-pip 

# Install prediction.io itself
RUN curl -O https://d8k1yxp8elc6b.cloudfront.net/PredictionIO-${PIO_VERSION}.tar.gz && \
    tar -xvzf PredictionIO-${PIO_VERSION}.tar.gz -C / && \
    mkdir -p ${PIO_HOME}/vendors && \
    rm PredictionIO-${PIO_VERSION}.tar.gz

# Add prediction.io configuration
ADD files/pio-env.sh ${PIO_HOME}/conf/pio-env.sh

# Install Elasticsearch
RUN curl -O https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz && \
    tar -xvzf elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz -C ${PIO_HOME}/vendors && \
    rm elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz && \
    echo 'cluster.name: predictionio' >> ${PIO_HOME}/vendors/elasticsearch-${ELASTICSEARCH_VERSION}/config/elasticsearch.yml && \
    echo 'network.host: 127.0.0.1' >> ${PIO_HOME}/vendors/elasticsearch-${ELASTICSEARCH_VERSION}/config/elasticsearch.yml

# Install HBase
RUN curl -O http://archive.apache.org/dist/hbase/hbase-${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz && \
    tar -xvzf hbase-${HBASE_VERSION}-bin.tar.gz -C ${PIO_HOME}/vendors && \
    rm hbase-${HBASE_VERSION}-bin.tar.gz && \
    rm -rf ${PIO_HOME}/vendors/hbase-${HBASE_VERSION}/docs

# Add HBase configuration template
ADD files/hbase-site.xml ${PIO_HOME}/vendors/hbase-${HBASE_VERSION}/conf/hbase-site.xml

# Configure HBase configuration template
RUN sed -i "s|%%PIO_HOME%%|${PIO_HOME}|" ${PIO_HOME}/vendors/hbase-${HBASE_VERSION}/conf/hbase-site.xml && \
    sed -i "s|%%HBASE_VERSION%%|${HBASE_VERSION}|" ${PIO_HOME}/vendors/hbase-${HBASE_VERSION}/conf/hbase-site.xml

# Install Spark
RUN curl -O http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}-bin-hadoop2.6.tgz && \
    tar -xvzf spark-${SPARK_VERSION}-bin-hadoop2.6.tgz -C ${PIO_HOME}/vendors && \
    rm spark-${SPARK_VERSION}-bin-hadoop2.6.tgz && \
    rm -rf ${PIO_HOME}/vendors/spark-${SPARK_VERSION}-bin-hadoop2.6/examples

# Triggers fetching the complete sbt environment
RUN ${PIO_HOME}/sbt/sbt -batch

# Add scripts
ADD files/deploy_engine.sh .
ADD files/entrypoint.sh .

RUN chmod +x entrypoint.sh && chmod +x deploy_engine.sh

# Expose HTTP ports (event server and recommendation server)
EXPOSE 7070 8000

# Entrypoint definition -> Run services
ENTRYPOINT ["/entrypoint.sh"]
