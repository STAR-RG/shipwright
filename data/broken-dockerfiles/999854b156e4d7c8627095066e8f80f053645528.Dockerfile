FROM nimmis/java:oracle-8-jdk

MAINTAINER wendal "wendal1985@gmail.com"

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.0.24
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz


RUN cd $CATALINA_HOME \
	&&wget -O tomcat.tar.gz $TOMCAT_TGZ_URL \
	&& tar -xvf tomcat.tar.gz --strip-components=1 \
	&& cd $CATALINA_HOME \
	&& rm bin/*.bat \
	&& rm tomcat.tar.gz* && rm -fr /usr/local/tomcat/webapps/ROOT \
	&& rm -fr /usr/local/tomcat/webapps/docs /usr/local/tomcat/webapps/host-manager /usr/local/tomcat/webapps/manager /usr/local/tomcat/webapps/examples


ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_TGZ_URL https://www.apache.org/dist/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz

RUN mkdir /tmp2 && cd /tmp2 \
  && curl -sSL $MAVEN_TGZ_URL | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-3.3.3 /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
  && curl -sSL https://github.com/Rekoe/Rk_Cms/archive/master.tar.gz | tar xzf - -C /tmp2 \
  && cd /tmp2 && ls -l  && cd Rk_Cms-master \
  && mvn -f pom_docker.xml clean package \
  && mkdir -p /usr/local/tomcat/webapps/ROOT \
  && cp -r target/rk_cms/* /usr/local/tomcat/webapps/ROOT/ \
  && find /usr/local/tomcat/webapps/ROOT/ \
  && cd / \
  && rm -fr /tmp2 usr/share/maven /usr/bin/mvn ~/.m2
	
WORKDIR $CATALINA_HOME

EXPOSE 8080

RUN cd $CATALINA_HOME/webapps/ROOT/WEB-INF/classes/ && sed -i 's/192.168.3.157/db/g' jdbc.properties

CMD ["catalina.sh", "run"]