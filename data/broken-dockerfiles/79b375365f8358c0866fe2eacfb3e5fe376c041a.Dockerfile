FROM alpine

MAINTAINER mmolimar

ARG VERSION

ENV JAVA_ALPINE_VERSION 8.131.11-r2

RUN apk update && apk add openjdk8-jre="$JAVA_ALPINE_VERSION"

WORKDIR /vkitm
COPY build/libs/vkitm-${VERSION}.jar /vkitm/vkitm.jar

CMD java -jar /vkitm/vkitm.jar /vkitm/conf/application.conf
