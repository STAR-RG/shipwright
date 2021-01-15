FROM wnameless/mysql-phpmyadmin

MAINTAINER Wei-Ming Wu <wnameless@gmail.com>

# Install libfuse2
RUN apt-get install -y libfuse2; \
	cd /tmp; \
	apt-get download fuse; \
	dpkg-deb -x fuse_* .; \
	dpkg-deb -e fuse_*; \
	rm fuse_*.deb; \
	echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst; \
	dpkg-deb -b . /fuse.deb; \
	dpkg -i /fuse.deb

# Install Java 7
RUN apt-get install -y openjdk-7-jdk

# Install Tomcat 7
RUN apt-get install -y tomcat7 tomcat7-admin
RUN sed -i "s#</tomcat-users>##g" /etc/tomcat7/tomcat-users.xml; \
	echo '  <role rolename="manager-gui"/>' >>  /etc/tomcat7/tomcat-users.xml; \
	echo '  <role rolename="manager-script"/>' >>  /etc/tomcat7/tomcat-users.xml; \
	echo '  <role rolename="manager-jmx"/>' >>  /etc/tomcat7/tomcat-users.xml; \
	echo '  <role rolename="manager-status"/>' >>  /etc/tomcat7/tomcat-users.xml; \
	echo '  <role rolename="admin-gui"/>' >>  /etc/tomcat7/tomcat-users.xml; \
	echo '  <role rolename="admin-script"/>' >>  /etc/tomcat7/tomcat-users.xml; \
	echo '  <user username="admin" password="admin" roles="manager-gui, manager-script, manager-jmx, manager-status, admin-gui, admin-script"/>' >>  /etc/tomcat7/tomcat-users.xml; \
	echo '</tomcat-users>' >> /etc/tomcat7/tomcat-users.xml

# Configure https
RUN sed -i "s#</Server>##g" /etc/tomcat7/server.xml; \
	sed -i "s#  </Service>##g" /etc/tomcat7/server.xml; \
	echo '    <Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true" maxThreads="150" scheme="https" secure="true" clientAuth="false" sslProtocol="TLS" keystoreFile="/usr/share/tomcat7/.keystore" keystorePass="tomcat_admin" />' >> /etc/tomcat7/server.xml; \
	echo '  </Service>' >> /etc/tomcat7/server.xml; \
	echo '</Server>' >> /etc/tomcat7/server.xml

# Install CAS server
RUN cd /tmp; \
	wget http://downloads.jasig.org/cas/cas-server-3.5.2-release.tar.gz; \
	tar xzvf cas-server-3.5.2-release.tar.gz; \
    cp cas-server-3.5.2/modules/cas-server-webapp-3.5.2.war /var/lib/tomcat7/webapps/cas.war; \
    service tomcat7 start; \
    sleep 10; \
    service tomcat7 stop; \
    cp cas-server-3.5.2/modules/cas-server-support-jdbc-3.5.2.jar /var/lib/tomcat7/webapps/cas/WEB-INF/lib

# Create CAS authentication DB
RUN chmod 1777 /tmp; \
	mysqld & \
	sleep 5; \
	echo "CREATE DATABASE cas" | mysql -u root; \
	echo "CREATE TABLE cas_users (id INT AUTO_INCREMENT NOT NULL, username VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL, password VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL, PRIMARY KEY (id), UNIQUE KEY (username))"| mysql -u root -D cas; \
	echo "INSERT INTO cas_users (username, password) VALUES ('guest', '084e0343a0486ff05530df6c705c8bb4')" | mysql -u root -D cas; \
	sleep 10

# Replace CAS deployerConfigContext.xml & install MySQL driver
ADD deployerConfigContext.xml /
ADD mysql-connector-java-5.1.28-bin.jar /
RUN mv deployerConfigContext.xml /var/lib/tomcat7/webapps/cas/WEB-INF/deployerConfigContext.xml; \
	mv mysql-connector-java-5.1.28-bin.jar /var/lib/tomcat7/webapps/cas/WEB-INF/lib

EXPOSE 22
EXPOSE 80
EXPOSE 3306
EXPOSE 8080
EXPOSE 8443

CMD chmod 1777 /tmp; \
	mysqld_safe & \
	service apache2 start; \
	[ ! -f /usr/share/tomcat7/.keystore ] && printf tomcat_admin\\ntomcat_admin\\n\\n\\n\\n\\n\\n\\ny\\ntomcat_admin\\ntomcat_admin\\n | keytool -genkey -alias tomcat -keyalg RSA -keystore /usr/share/tomcat7/.keystore; \
	service tomcat7 start; \
	/usr/sbin/sshd -D
