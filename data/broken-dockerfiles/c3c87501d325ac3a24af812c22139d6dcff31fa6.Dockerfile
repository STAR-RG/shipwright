FROM tomcat:8.0
RUN mkdir /src
RUN mkdir /data
RUN ln -s /data /var/opengrok
RUN ln -s /src /var/opengrok/src
RUN wget "https://java.net/projects/opengrok/downloads/download/opengrok-0.12.1.5.tar.gz" -O /tmp/opengrok-0.12.1.5.tar.gz
RUN wget "http://ftp.us.debian.org/debian/pool/main/e/exuberant-ctags/exuberant-ctags_5.9~svn20110310-8_amd64.deb" -O /tmp/exuberant-ctags_5.9-svn20110310-8_amd64.deb
RUN tar zxvf /tmp/opengrok-0.12.1.5.tar.gz -C /
RUN dpkg -i /tmp/exuberant-ctags_5.9-svn20110310-8_amd64.deb

ENV SRC_ROOT /src
ENV OPENGROK_TOMCAT_BASE /usr/local/tomcat
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
ENV PATH /opengrok-0.12.1.5/bin:$PATH

ENV CATALINA_BASE /usr/local/tomcat
ENV CATALINA_HOME /usr/local/tomcat
ENV CATALINA_TMPDIR /usr/local/tomcat/temp
ENV JRE_HOME /usr
ENV CLASSPATH /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar

WORKDIR $CATALINA_HOME
RUN /opengrok-0.12.1.5/bin/OpenGrok deploy

EXPOSE 8080
ADD scripts /scripts
CMD ["/scripts/start.sh"]
