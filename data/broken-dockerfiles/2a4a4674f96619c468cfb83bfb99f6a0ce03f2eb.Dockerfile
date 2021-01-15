FROM java:11
MAINTAINER George Varghese 
LABEL Description="Image for swagger Single Documentation Server for Microservices" Version="1.0"
RUN mkdir /app
VOLUME /tmp
ADD target/*.jar /app/application.jar
EXPOSE 8012
#RUN bash -c 'touch /app.jar'
#ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
CMD java $JAVA_OPTS -jar /app/application.jar