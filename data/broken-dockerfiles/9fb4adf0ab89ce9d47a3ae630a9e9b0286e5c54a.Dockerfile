# syntax=docker/dockerfile:experimental
ARG openjdkversion=alpine
FROM adoptopenjdk/maven-openjdk8-openj9 as builder
LABEL maintainer="Pasquale Paola <pasquale.paola@gmail.com>"
WORKDIR /app
#COPY settings.xml /root/.m2/
COPY ./ /app/
RUN  --mount=type=cache,target=/root/.m2 mvn  -e -B package

FROM adoptopenjdk/openjdk8-openj9:$openjdkversion as kiss-main-service
LABEL maintainer="Pasquale Paola <pasquale.paola@gmail.com>"
COPY --from=builder  /app/api/target/api-0.0.1-SNAPSHOT.jar /usr/kiss/
WORKDIR /usr/kiss
EXPOSE 8080
CMD ["java", "-XX:MaxRAM=4G", "-Djava.security.egd=file:/dev/./urandom", "-jar", "api-0.0.1-SNAPSHOT.jar"]

FROM httpd:2.4.39 as kiss-httpd
LABEL maintainer="Pasquale Paola <pasquale.paola@gmail.com>"
EXPOSE 80
COPY httpd/proxy-html.conf /usr/local/apache2/conf/extra/
COPY httpd/httpd.conf /usr/local/apache2/conf/


