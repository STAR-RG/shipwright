FROM debian:jessie
MAINTAINER Gerald Oster <oster@loria.fr>

RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y -q apt-utils  curl ca-certificates git unzip

RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get update -qq && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default  && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/*
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN curl -O http://downloads.typesafe.com/scala/2.11.7/scala-2.11.7.tgz && \ 
    tar xvfz scala-2.11.7.tgz -C / && \
	rm scala-2.11.7.tgz
ENV SCALA_HOME /scala-2.11.7
ENV PATH $PATH:$SCALA_HOME/bin

RUN mkdir /app

WORKDIR /app
EXPOSE 9000 9443

ADD ["target/universal/stage", "/app/webplm-dist"]

WORKDIR /app/webplm-dist
CMD ["bin/web-plm", "-Dhttps.port=9443", "-mem", "4096", "-J-server"]
