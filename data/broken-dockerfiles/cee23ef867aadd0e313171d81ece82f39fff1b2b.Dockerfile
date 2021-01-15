FROM maven:latest
RUN mkdir -p /opt/application
WORKDIR /opt/application
RUN git clone https://github.com/wu191287278/sc-generator.git
WORKDIR /opt/application/sc-generator
EXPOSE 8090:8090 5005:5005
VOLUME ["/tmp","/root/.m2"]
ENV JAVA_OPTS="-server -Xms512M -Xmx512M -Xss512k -XX:PermSize=256M"
CMD java -jar /opt/application/sc-generator/target/sc-generator.jar
