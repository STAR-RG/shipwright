FROM maven
MAINTAINER He Bai <bai.he@outlook.com>

WORKDIR /opt

ADD disconf/ /disconf

# Environment variables
ENV TOMCAT_VERSION 8.0.33
ENV DISCONF_REPO https://github.com/knightliao/disconf
ENV ONLINE_CONFIG_PATH /disconf/conf
ENV WAR_ROOT_PATH /disconf/war

# Add required jars into a extra libarary directory
RUN git clone ${DISCONF_REPO} && cd disconf/disconf-web && sh deploy/deploy.sh && cd -

RUN wget http://mirrors.noc.im/apache/tomcat/tomcat-8/v8.0.33/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && tar xvzf apache-tomcat-${TOMCAT_VERSION}.tar.gz
ADD disconf/conf/server.xml /opt/apache-tomcat-${TOMCAT_VERSION}/conf/server.xml

CMD /opt/apache-tomcat-${TOMCAT_VERSION}/bin/catalina.sh run




