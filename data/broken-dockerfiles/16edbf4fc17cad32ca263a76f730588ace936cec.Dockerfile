FROM ubuntu
MAINTAINER vishnu@cloudron.in

RUN \
   apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
   echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list && \
   apt-get update && \
   apt-get install -y mongodb-org

RUN apt-get update --fix-missing
RUN apt-get install -y --fix-missing wget default-jdk
ENV JAVA_HOME /usr/lib/jvm/default-java


ADD http://www.us.apache.org/dist/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz /tmp/
RUN tar xzvf /tmp/apache-maven-3.3.3-bin.tar.gz --directory /usr/lib
ENV PATH /usr/lib/apache-maven-3.3.3/bin:$PATH
RUN mkdir -p /opt/cyber-event-collector
ADD src /opt/cyber-event-collector/src
ADD pom.xml /opt/cyber-event-collector/pom.xml
RUN mvn --file /opt/cyber-event-collector/pom.xml clean install

VOLUME ["/data/db"]
WORKDIR /data

EXPOSE 27017

ADD server.sh /
RUN chmod u+x /server.sh
CMD ["/server.sh"]

