FROM consol/tomcat-7.0

MAINTAINER Friedrich Große <friedrich.grosse@gmail.com>
ENV KUNAGI_VERSION 0.26

EXPOSE 8080
ENV DEPLOY_DIR /kunagi

RUN wget http://kunagi.org/releases/${KUNAGI_VERSION}/kunagi.war --directory-prefix=kunagi

CMD /opt/tomcat/bin/deploy-and-run.sh
