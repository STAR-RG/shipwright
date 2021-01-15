# Pull base image
FROM ubuntu:14.04

# Maintainer
MAINTAINER  SWAN Team https://github.com/annefried/swan

ENV         JAVA_HOME         /usr/lib/jvm/java-8-oracle
ENV         GLASSFISH_HOME    /usr/local/glassfish4
ENV         PATH              $PATH:$JAVA_HOME/bin:$GLASSFISH_HOME/bin

RUN         echo "--- Update and upgrade Ubuntu ---" && \
            apt-get update && \
            apt-get -y upgrade && \
            apt-get -y install software-properties-common && \
            apt-get -y install python-software-properties && \
            add-apt-repository -y ppa:webupd8team/java && \
            apt-get update && \

            echo "--- Install JDK8 ---" && \
            echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
            apt-get install -y oracle-java8-installer && \
            rm -rf /var/cache/oracle-jdk8-installer && \

            echo "--- Download and install GlassFish 4.1 ---" && \
            apt-get -y install curl unzip zip inotify-tools && \
            rm -rf /var/lib/apt/lists/* && \
            curl -L -o /tmp/glassfish-4.1.zip http://download.java.net/glassfish/4.1/release/glassfish-4.1.zip && \
            unzip /tmp/glassfish-4.1.zip -d /usr/local && \
            rm -f /tmp/glassfish-4.1.zip

EXPOSE      4848 8080 8181

WORKDIR     /usr/local/glassfish4

# Verbose causes the process to remain in the foreground so that docker can track it
CMD         asadmin start-domain --verbose