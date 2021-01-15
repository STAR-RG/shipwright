 # Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 #
 # Licensed under the Apache License, Version 2.0 (the "License").
 # You may not use this file except in compliance with the License.
 # A copy of the License is located at
 #
 #  http://aws.amazon.com/apache2.0
 #
 # or in the "license" file accompanying this file. This file is distributed
 # on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 # express or implied. See the License for the specific language governing
 # permissions and limitations under the License.


FROM phusion/baseimage

# Install Java.
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

WORKDIR /srv/jetty

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

ADD target/scala-2.11/akka-firehose-assembly-*.jar srv/jetty/
CMD java -server    -XX:+DoEscapeAnalysis -XX:+UseStringDeduplication -XX:+UseCompressedOops \
                    -XX:+UseG1GC -jar srv/jetty/akka-firehose-assembly-*.jar
