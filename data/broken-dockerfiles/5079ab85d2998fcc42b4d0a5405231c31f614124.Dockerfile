# LICENCE : CloudUnit is available under the Affero Gnu Public License GPL V3 : https://www.gnu.org/licenses/agpl-3.0.html
# but CloudUnit is licensed too under a standard commercial license.
# Please contact our sales team if you would like to discuss the specifics of our Enterprise license.
# If you are not sure whether the GPL is right for you,
# you can always test our software under the GPL and inspect the source code before you contact us
# about purchasing a commercial license.

# LEGAL TERMS : "CloudUnit" is a registered trademark of Treeptik and can't be used to endorse
# or promote products derived from this project without prior written permission from Treeptik.
# Products or services derived from this software may not be called "CloudUnit"
# nor may "Treeptik" or similar confusing terms appear in their names without prior written permission.
# For any questions, contact us : contact@treeptik.fr

#CU-MANAGER Dockerfile

FROM ubuntu:14.04

# Passage du système en UTF-8
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV MAVEN_HOME /usr/share/maven
ENV JAVA_HOME /cloudunit/java/jdk1.8.0_25

# Dépendances Debian
RUN apt-get update \
    && apt-get install -y curl \
    && apt-get install -y git \
    && apt-get install -y wget \
    && apt-get install -y git-core \
    && apt-get install -y libltdl7 \
    && apt-get install -y unzip \
        && rm -r /var/lib/apt/lists/*

# Fix pour permettre de tirer correctement certaines dépendances
RUN git config --global url."https://".insteadOf git://

RUN wget https://github.com/Treeptik/CloudUnit/releases/download/1.0/apache-maven-3.3.3-bin.tar.gz -O /tmp/apache-maven-3.3.3-bin.tar.gz
RUN tar -xvf /tmp/apache-maven-3.3.3-bin.tar.gz -C /usr/share && rm /tmp/apache-*
RUN mv /usr/share/apache-maven-3.3.3 /usr/share/maven && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

RUN mkdir -p /cloudunit/java && wget https://github.com/Treeptik/cloudunit/releases/download/1.0/jdk-8u25-linux-x64.tar.gz -O /tmp/jdk-8u25-linux-x64.tar.gz
RUN tar -xvf /tmp/jdk-8u25-linux-x64.tar.gz -C /cloudunit/java
RUN rm /tmp/jdk-*

RUN mkdir -p /home/cloudunit/app/CloudUnit

WORKDIR /home/cloudunit/app

# import git repository
COPY . /home/cloudunit/app/CloudUnit/

# Add nodesource PPA for specific version of node and install
RUN curl -sL https://deb.nodesource.com/setup_5.x | bash -
RUN apt-get update && apt-get install -y nodejs

# Fix npm
RUN cd /usr/lib/node_modules/npm \
&& npm install fs-extra \
&& sed -i -e s/graceful-fs/fs-extra/ -e s/fs\.move/fs.rename/ ./lib/utils/rename.js

RUN npm install -g grunt grunt-cli bower
RUN cd /home/cloudunit/app/CloudUnit/cu-manager-ui && npm install
RUN cd /home/cloudunit/app/CloudUnit/cu-manager-ui && bower --allow-root install
RUN cd /home/cloudunit/app/CloudUnit/cu-manager-ui && grunt build -f

# Build Maven with profiles
RUN cd /home/cloudunit/app/CloudUnit/ && mvn clean install -DskipTests -Pdefault -Dmaven.repo.local=/opt/maven/.m2
RUN rm -rf /opt/maven/.m2 /home/cloudunit/app/CloudUnit/cu-manager-ui/node_modules /home/cloudunit/app/CloudUnit/cu-manager-ui/bower_components

ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/scripts

# Install Tomcat
RUN wget http://archive.apache.org/dist/tomcat/tomcat-8/v8.0.38/bin/apache-tomcat-8.0.38.tar.gz && \
        tar -xvf apache-tomcat-8.0.38.tar.gz && \
        rm apache-tomcat*.tar.gz && \
        mv apache-tomcat* ${CATALINA_HOME}

RUN chmod +x ${CATALINA_HOME}/bin/*sh

WORKDIR /opt/tomcat
RUN rm -rf /opt/tomcat/webapps/*
RUN cp -rf /home/cloudunit/app/CloudUnit/cu-manager/target/ROOT.war /opt/tomcat/webapps
RUN ls -la /opt/tomcat/webapps
RUN unzip /home/cloudunit/app/CloudUnit/cu-manager/target/ROOT.war -d /opt/tomcat/webapps/ROOT
RUN cp -rf /home/cloudunit/app/CloudUnit/cu-manager-ui/dist/* /opt/tomcat/webapps/ROOT
ADD ./cu-manager/dockerhub/tomcat.sh $CATALINA_HOME/scripts/tomcat.sh
RUN chmod +x $CATALINA_HOME/scripts/*
EXPOSE 8080

CMD ["tomcat.sh"]
