FROM selenium/standalone-firefox:latest

ENV MAVEN_VERSION 3.3.3

USER root
  
RUN apt-get update -qqy \
  && apt-get -qqy --no-install-recommends install \
    openjdk-7-jdk \
  && rm -rf /var/lib/apt/lists/*

RUN wget -O- http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /opt \
  && mv /opt/apache-maven-$MAVEN_VERSION /opt/maven \
  && ln -s /opt/maven/bin/mvn /usr/bin/mvn

USER seluser

ENV MAVEN_HOME /opt/maven

CMD ["mvn"]