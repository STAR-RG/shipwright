FROM maven:3.3.3-jdk-7
MAINTAINER Ivan Pedrazas <ipedrazas@gmail.com>

RUN  \
  export DEBIAN_FRONTEND=noninteractive && \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y git npm

RUN git clone https://github.com/apache/incubator-zeppelin.git /zeppelin

WORKDIR /zeppelin

RUN mvn clean package -Pcassandra-spark-1.5 -Dhadoop.version=2.6.0 -Phadoop-2.6 -DskipTests

EXPOSE 8080

CMD ["bin/zeppelin.sh", "start"]
