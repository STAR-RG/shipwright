FROM maven:3.5.2-jdk-8-alpine AS BUILD_IMAGE
RUN rm -r /tmp/
COPY pom.xml /tmp/
COPY src /tmp/src/
COPY .git /tmp/.git/
WORKDIR /tmp/
RUN mvn -Pdev clean install package

FROM openjdk:8-jdk-alpine
COPY --from=BUILD_IMAGE /tmp/target/multipledatabasespring*.jar ./multipledatabasespring.jar
ENTRYPOINT ["/usr/bin/java"]
CMD ["-jar", "/multipledatabasespring.jar"]
VOLUME /var/lib/multipledatabasespring/config-repo
EXPOSE 8080
