FROM centos:centos6
MAINTAINER Guuuo <im@kuo.io>

#update
RUN yum -y update; yum clean all
#install tools
RUN yum install -y wget unzip tar
#install supervisor
RUN yum install -y python-setuptools
RUN easy_install supervisor
RUN mkdir -p /var/log/supervisor

#install httpd
RUN yum -y install httpd

#config httpd
RUN mkdir -p /data
ADD conf/httpd/wwwroot /data/wwwroot
ADD conf/httpd/wwwconf /data/wwwconf
ADD conf/httpd/httpd.conf /etc/httpd/conf/httpd.conf

#install jdk
ENV JAVA_VERSION 8u45
ENV BUILD_VERSION b14
RUN wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$BUILD_VERSION/jdk-$JAVA_VERSION-linux-x64.rpm" -O /tmp/jdk-8-linux-x64.rpm
RUN yum -y install /tmp/jdk-8-linux-x64.rpm
RUN rm -rf /tmp/jdk-8-linux-x64.rpm
RUN alternatives --install /usr/bin/java jar /usr/java/latest/bin/java 200000
RUN alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000
RUN alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000
ENV JAVA_HOME /usr/java/latest

#install tomcat
ENV TOMCAT_VERSION 7.0.62
RUN wget http://mirrors.cnnic.cn/apache/tomcat/tomcat-7/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.zip -O /tmp/tomcat.zip
RUN unzip /tmp/tomcat.zip -d /tmp/
RUN rm -rf /tmp/tomcat.zip
RUN mkdir -p /data
RUN mv /tmp/apache-tomcat-$TOMCAT_VERSION /data/tomcat
RUN chmod 777 /data/tomcat/bin/*.sh
ADD conf/tomcat/tomcat-users.xml /data/tomcat/conf/tomcat-users.xml

#install make
RUN yum -y install gcc automake autoconf libtool make
#install openssl openssl-dev apr-devel
RUN yum -y install openssl openssl-devel apr-devel
#install tomcat-native
RUN cp /data/tomcat/bin/tomcat-native.tar.gz /tmp/tomcat-native.tar.gz 
RUN tar zxvf /tmp/tomcat-native.tar.gz -C /tmp; rm -rf /tmp/tomcat-native.tar.gz
RUN mv /tmp/tomcat-native-*-src /tmp/tomcat-native
WORKDIR /tmp/tomcat-native/jni/native
RUN chmod +x ./configure
RUN chmod +x ./build/*.sh
RUN ./configure --with-apr=/usr/bin/apr-1-config --with-java-home=$JAVA_HOME --with-ssl=yes
RUN make & make install
RUN rm -rf /tmp/tomcat-native
#config apr
ENV LD_LIBRARY_PATH /usr/local/apr/lib

#config supervisor
ADD conf/supervisor/supervisord.conf /etc/supervisord.conf
ADD conf/supervisor/supervisord_tomcat.sh /data/tomcat/bin/supervisord_tomcat.sh
RUN chmod +x /data/tomcat/bin/supervisord_tomcat.sh

EXPOSE 80 

CMD ["supervisord", "-n"] 