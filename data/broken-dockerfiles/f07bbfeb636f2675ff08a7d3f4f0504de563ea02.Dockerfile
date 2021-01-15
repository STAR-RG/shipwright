FROM java:8 

# Install maven
RUN apt-get update  
RUN apt-get install -y maven

WORKDIR /code

# Prepare by downloading dependencies
ADD pom.xml /code/pom.xml  
RUN ["mvn", "dependency:resolve"]  
RUN ["mvn", "verify"]

ENV API_KEY asdfasdfasdfsf

# Adding source, compile and package into a fat jar
ADD src /code/src  
RUN ["mvn", "package"]

EXPOSE 4567  
CMD ["sh", "target/bin/webapp"]  