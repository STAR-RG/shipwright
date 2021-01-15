FROM docker-registry.decisionbrain.loc/cplex-studio-java:12.9-jdk8-1.0.0

USER root

RUN apt-get update \
     && apt-get upgrade -y \
     && apt-get install -y sudo libltdl-dev \
     && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/share/ca-certificates/decisionbrain.loc
ADD http://ldap.decisionbrain.loc/ca.crt /usr/local/share/ca-certificates/decisionbrain.loc
RUN  update-ca-certificates

RUN keytool -import -noprompt -trustcacerts -alias loc -file /usr/local/share/ca-certificates/decisionbrain.loc/ca.crt -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit

RUN useradd jenkins --shell /bin/bash --uid 1001 --create-home

RUN chmod -R 755 /home/jenkins

USER decisionbrain