##### START tomcat

# Copyright (c) 2012-2016 Codenvy, S.A.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
# Contributors:
# Codenvy, S.A. - initial API and implementation

FROM debian:stretch
EXPOSE 8080
RUN apt-get update && \
    apt-get -y install locales sudo procps wget unzip gnupg && \
    apt-get -y install openjdk-8-jdk && \
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -u 1000 -G users,sudo -d /home/user --shell /bin/bash -m user \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

USER user

LABEL che:server:8080:ref=tomcat8 che:server:8080:protocol=http

ENV TOMCAT_HOME=/home/user/tomcat \
    TOMCAT8_VERSION=8.0.33

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64

ENV PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH

RUN mkdir $TOMCAT_HOME

ENV TERM xterm

RUN wget -qO- "http://archive.apache.org/dist/tomcat/tomcat-8/v$TOMCAT8_VERSION/bin/apache-tomcat-$TOMCAT8_VERSION.tar.gz" | tar -zx --strip-components=1 -C $TOMCAT_HOME && \
    rm -rf $TOMCAT_HOME/webapps/*

ENV LANG C.UTF-8
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64\nexport M2_HOME=/home/user/apache-maven-$MAVEN_VERSION\nexport TOMCAT_HOME=$TOMCAT_HOME\nexport PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH" >> /home/user/.bashrc && \
    sudo localedef -i en_US -f UTF-8 en_US.UTF-8

WORKDIR $TOMCAT_HOME
COPY conf/server.xml /home/user/tomcat/conf

##### END tomcat

ADD zenboot.properties /etc/zenboot/zenboot.properties
USER root
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" > /etc/apt/sources.list.d/ansible.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN sudo apt-get update && sudo apt-get install -y curl ansible openssh-client sshpass socat dnsutils jq less vim netcat-openbsd git \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*
ADD docker-provisioning/ansible.cfg /etc/ansible/ansible.cfg

## Install docker in order to potentially use docker via socket at runtime
RUN apt-get update && sudo apt-get install -y \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
RUN apt-key fingerprint 0EBFCD88 | grep -q "9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88"
RUN add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
      $(lsb_release -cs) \
      stable"
RUN apt-get update && apt-get install -y docker-ce

# Install kubectl
RUN curl -o /usr/local/bin/kubectl -LO https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kubectl \
      && chmod +x /usr/local/bin/kubectl

USER user

ARG VERSION
RUN if [ -z "$VERSION" ]; \
        then echo "the build argument 'VERSION' is mandatory"; \
        exit 1; \
    fi
ARG ZENBOOT_WAR=https://github.com/hybris/zenboot/releases/download/v$VERSION/zenboot.war
ARG ZENBOOT_CLI=https://github.com/hybris/zenboot/releases/download/v$VERSION/zenboot-linux-amd64

RUN mkdir -p /home/user/zenboot
ADD $ZENBOOT_WAR $TOMCAT_HOME/webapps/zenboot.war
ADD $ZENBOOT_CLI /usr/local/bin/zenboot
ADD docker-provisioning/setenv.sh $TOMCAT_HOME/bin/setenv.sh
RUN sudo chown user:user $TOMCAT_HOME/bin/setenv.sh
RUN sudo chown user:user $TOMCAT_HOME/webapps/zenboot.war
RUN sudo chmod +x /usr/local/bin/zenboot

CMD bin/catalina.sh run 2>&1
