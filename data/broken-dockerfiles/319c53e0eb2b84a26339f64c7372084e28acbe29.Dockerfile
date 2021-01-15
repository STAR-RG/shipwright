
FROM jboss/base-jdk:8

EXPOSE 9042 9160 7000 7001


ENV CASSANDRA_VERSION="3.11.4" \
    CASSANDRA_HOME="/opt/apache-cassandra" \
    HOME="/home/cassandra" \
    PATH="/opt/apache-cassandra/bin:$PATH" 


USER root

RUN yum install -y -q bind-utils && \
   yum clean all

RUN cd /opt &&\
	curl -LO http://apache.uvigo.es/cassandra/$CASSANDRA_VERSION/apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz && ls -l &&\ 
    tar xvzf apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz && \
    rm apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz && \
    ln -s apache-cassandra-$CASSANDRA_VERSION apache-cassandra


#COPY cassandra-lucene-index-plugin-3.0.10.3.jar \
#     /opt/apache-cassandra/lib/

#COPY cassandra-lucene-index-plugin-3.10.0-RC1-SNAPSHOT.jar \
#     /opt/apache-cassandra/lib/     

COPY docker-entrypoint.sh \
     /opt/apache-cassandra/bin/

COPY docker-entrypoint-stateful-sets.sh \
     /opt/apache-cassandra/bin/

     
ADD cassandra.yaml.template /opt/apache-cassandra/conf/cassandra.yaml

RUN groupadd -r cassandra -g 312 && \
    useradd -u 313 -r -g cassandra -d /opt/apache-cassandra -s /sbin/nologin cassandra && \
    chown -R cassandra:cassandra /opt/apache-cassandra && \
    chmod -R go+rw /opt/apache-cassandra && \
    mkdir $HOME && \
    chown -R cassandra:cassandra $HOME && \
    chmod -R go+rw $HOME

RUN  mkdir -p /var/lib/cassandra \
	&& chown -R cassandra:cassandra /var/lib/cassandra \
	&& chmod 777 /var/lib/cassandra  && chmod +x /opt/apache-cassandra/bin/docker-entrypoint.sh && chmod +x /opt/apache-cassandra/bin/docker-entrypoint-stateful-sets.sh

USER 313	

VOLUME /var/lib/cassandra


