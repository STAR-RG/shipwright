FROM maven:3.5.3-jdk-8 AS build
COPY main /usr/jh/main
COPY common /usr/jh/common
COPY pom.xml /usr/jh
RUN mvn -f /usr/jh/pom.xml clean package

FROM openjdk:8
COPY --from=build /usr/jh/main/target/main-1.0.0.jar /usr/jh/jh.jar
EXPOSE 8484
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/urandom", "-jar", "/usr/jh/jh.jar"]
CMD ["bash"]
