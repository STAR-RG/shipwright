FROM openjdk:8-jdk-stretch as builder
ADD . /kafka
WORKDIR  /kafka
RUN ./gradlew -PscalaVersion=2.12 clean releaseTarGz


FROM openjdk:8-jdk-slim-stretch
WORKDIR /opt/kafka
COPY --from=builder /kafka/core/build/distributions/kafka_2.12-2.0.0-SNAPSHOT.tgz /tmp
RUN tar -xzf /tmp/kafka_2.12-2.0.0-SNAPSHOT.tgz -C /opt/kafka --strip-components=1
