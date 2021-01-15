FROM debian:jessie

# install and configure supervisor
RUN apt-get update && apt-get install -y supervisor && mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# install java & curl
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN apt-get -y update
RUN /bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install oracle-java7-installer oracle-java7-set-default curl

# download and install spark
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.3.0-bin-hadoop2.4.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.3.0-bin-hadoop2.4 spark

# install cassandra
ENV CASSANDRA_VERSION 2.1.8
RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 514A2AD631A57A16DD0047EC749D6EEC0353B12C
RUN echo 'deb http://www.apache.org/dist/cassandra/debian 21x main' >> /etc/apt/sources.list.d/cassandra.list
RUN apt-get update \
	&& apt-get install -y cassandra="$CASSANDRA_VERSION" \
	&& rm -rf /var/lib/apt/lists/*

# copy some script to run spark
COPY scripts/start-master.sh /start-master.sh
COPY scripts/start-worker.sh /start-worker.sh
COPY scripts/spark-shell.sh /spark-shell.sh
COPY scripts/spark-cassandra-connector-assembly-1.3.0-RC1-SNAPSHOT.jar /spark-cassandra-connector-assembly-1.3.0-RC1-SNAPSHOT.jar
COPY scripts/spark-defaults.conf /spark-defaults.conf

# configure spark
ENV SPARK_HOME /usr/local/spark
ENV SPARK_MASTER_OPTS="-Dspark.driver.port=7001 -Dspark.fileserver.port=7002 -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004 -Dspark.blockManager.port=7005 -Dspark.executor.port=7006 -Dspark.ui.port=4040 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"
ENV SPARK_WORKER_OPTS=$SPARK_MASTER_OPTS
ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_WORKER_PORT 8888
ENV SPARK_WORKER_WEBUI_PORT 8081

# configure cassandra
ENV CASSANDRA_CONFIG /etc/cassandra

# listen to all rpc
RUN sed -ri ' \
		s/^(rpc_address:).*/\1 0.0.0.0/; \
	' "$CASSANDRA_CONFIG/cassandra.yaml"

COPY cassandra-configurator.sh /cassandra-configurator.sh
ENTRYPOINT ["/cassandra-configurator.sh"]

VOLUME /var/lib/cassandra

### Spark
# 4040: spark ui
# 7001: spark driver
# 7002: spark fileserver
# 7003: spark broadcast
# 7004: spark replClassServer
# 7005: spark blockManager
# 7006: spark executor
# 7077: spark master
# 8080: spark master ui
# 8081: spark worker ui
# 8888: spark worker
### Cassandra
# 7000: C* intra-node communication
# 7199: C* JMX
# 9042: C* CQL
# 9160: C* thrift service
EXPOSE 4040 7000 7001 7002 7003 7004 7005 7006 7077 7199 8080 8081 8888 9042 9160

CMD ["/usr/bin/supervisord"]