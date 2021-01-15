FROM centos:latest

RUN yum -y update && yum clean all \
&& yum -y install epel-release \
&& yum -y install vim bash-completion tree git curl wget telnet

RUN yum install -y python34 \
&& yum -y install python-pip


ENV JAVA_HOME=/usr/java/default
RUN mkdir -p /usr/java \
&& curl -O -L --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
"http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jdk-8u60-linux-x64.tar.gz" \
&& tar -xvf jdk-8u60-linux-x64.tar.gz -C /usr/java \
&& ln -s /usr/java/jdk1.8.0_60/ /usr/java/default \
&& rm -f jdk-8u60-linux-x64.tar.gz


ENV SPARK_HOME=/usr/spark/default
RUN mkdir -p /usr/spark \
&& curl -O -L http://www-eu.apache.org/dist/spark/spark-1.6.1/spark-1.6.1-bin-hadoop2.6.tgz \
&& tar -xvf spark-1.6.1-bin-hadoop2.6.tgz -C /usr/spark \
&& ln -s /usr/spark/spark-1.6.1-bin-hadoop2.6/ /usr/spark/default \
&& rm -f spark-1.6.1-bin-hadoop2.6.tgz

COPY log4j.properties /usr/spark/default/conf/log4j.properties
COPY install_spark_executables.sh /install_spark_executables.sh
RUN /install_spark_executables.sh
