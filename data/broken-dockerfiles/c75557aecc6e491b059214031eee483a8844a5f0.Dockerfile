FROM ubuntu:14.04

MAINTAINER Raul Cumplido <raulcumplido@gmail.com>

WORKDIR /opt

# Install supervisor, wget and java
RUN apt-get update
RUN apt-get install -y software-properties-common supervisor wget
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
RUN echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
RUN apt-get install -y oracle-java8-set-default

# Download ELK
RUN wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz
RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.tar.gz
RUN wget https://download.elasticsearch.org/kibana/kibana/kibana-4.0.0-beta3.tar.gz

# Extract files
RUN tar -zxf logstash-1.4.2.tar.gz
RUN tar -zxf elasticsearch-1.4.2.tar.gz
RUN tar -zxf kibana-4.0.0-beta3.tar.gz

# Copy supervisor configuration
ADD conf/supervisor_kibana.conf /etc/supervisor/conf.d/kibana.conf
ADD conf/supervisor_elasticsearch.conf /etc/supervisor/conf.d/elasticsearch.conf
ADD conf/supervisor_logstash.conf /etc/supervisor/conf.d/logstash.conf

# Copy logstash configuration
ADD conf/logstash_simple.conf /opt/logstash/conf/logstash_simple.conf

EXPOSE 5601

CMD [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]
