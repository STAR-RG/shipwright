# syntax=docker/dockerfile:1.0-experimental
ARG openjdkversion=11-jre-openj9
FROM maven:3.6-jdk-11-slim as builder
WORKDIR /app
#COPY settings.xml /root/.m2/
COPY ./delivery-service ./delivery-service
COPY ./kitchen-service ./kitchen-service
COPY ./order-service ./order-service
COPY pom.xml ./
RUN  --mount=type=cache,target=/root/.m2/ mvn  -e  -B package


FROM adoptopenjdk:$openjdkversion as order-service
COPY --from=builder  /app/order-service/target/order-service-1.0-SNAPSHOT.jar /usr/order-service/
WORKDIR /usr/order-service
EXPOSE 8090
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-Dserver.port=8090", "-jar", "order-service-1.0-SNAPSHOT.jar"]


FROM adoptopenjdk:$openjdkversion as kitchen-service
COPY --from=builder  /app/kitchen-service/target/kitchen-service-1.0-SNAPSHOT.jar /usr/kitchen-service/
WORKDIR /usr/kitchen-service
EXPOSE 8080
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-Dserver.port=8080", "-jar", "kitchen-service-1.0-SNAPSHOT.jar"]


FROM adoptopenjdk:$openjdkversion as delivery-service
COPY --from=builder  /app/delivery-service/target/delivery-service-1.0-SNAPSHOT.jar /usr/delivery-service/
WORKDIR /usr/delivery-service
EXPOSE 8070
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-Dserver.port=8070", "-jar", "delivery-service-1.0-SNAPSHOT.jar"]

FROM kong as kong-mcpaspao
ENV KONG_DATABASE=off KONG_DECLARATIVE_CONFIG=/usr/local/kong/declarative/kong.yml KONG_PROXY_ACCESS_LOG=/dev/stdout KONG_ADMIN_ACCESS_LOG=/dev/stdout KONG_PROXY_ERROR_LOG=/dev/stderr KONG_ADMIN_ERROR_LOG=/dev/stderr KONG_ADMIN_LISTEN="0.0.0.0:8001, 0.0.0.0:8444 ssl"
COPY kong.yml /usr/local/kong/declarative/
EXPOSE 8000 8443 8001 8444

