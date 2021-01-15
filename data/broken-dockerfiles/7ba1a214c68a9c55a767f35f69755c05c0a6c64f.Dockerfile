# Java, Jetty and Cargo
#
# WEBSITE https://github.com/mthenw/docker-jetty-cargo
# VERSION 0.5.0

FROM java:7
MAINTAINER Maciej Winnicki "maciej.winnicki@gmail.com"

# Install Jetty
RUN wget -O /opt/jetty.tar.gz "http://eclipse.org/downloads/download.php?file=/jetty/9.0.7.v20131107/dist/jetty-distribution-9.0.7.v20131107.tar.gz&r=1"
RUN tar -xvf /opt/jetty.tar.gz -C /opt/
RUN rm /opt/jetty.tar.gz
RUN mv /opt/jetty-distribution-9.0.7.v20131107 /opt/jetty
RUN rm -rf /opt/jetty/webapps.demo
RUN useradd jetty -U -s /bin/false
RUN chown -R jetty:jetty /opt/jetty

# Install Cargo
ADD http://repo1.maven.org/maven2/org/codehaus/cargo/cargo-jetty-7-and-onwards-deployer/1.4.4/cargo-jetty-7-and-onwards-deployer-1.4.4.war /opt/jetty/webapps/cargo-jetty-7-and-onwards-deployer-1.4.4.war

# Run Jetty
EXPOSE 8080
CMD ["java", "-Djetty.home=/opt/jetty", "-jar", "/opt/jetty/start.jar"]
