FROM java:8

MAINTAINER takecy

ENV APP_HOME=/usr/local/vertx

WORKDIR /data

EXPOSE 80 8080

VOLUME . /data

RUN apt-get update && apt-get install -y nginx
RUN mkdir -p /usr/local/vertx
RUN mkdir -p /var/log/vertx

ADD . /data

CMD ["bash"]

ENTRYPOINT java -jar -server /usr/local/vertx/api.jar
