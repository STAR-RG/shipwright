FROM java:8

RUN  \
  export DEBIAN_FRONTEND=noninteractive && \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y vim wget curl git maven

RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> ~/.bashrc

ENV JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/jre"
ENV PATH $JAVA_HOME/bin:$PATH

VOLUME /home

RUN mkdir -p /home
WORKDIR /home

ADD ./pom.xml /home

RUN mvn clean install

