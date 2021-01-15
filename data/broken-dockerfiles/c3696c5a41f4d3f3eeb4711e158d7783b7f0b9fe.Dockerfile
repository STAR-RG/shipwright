FROM lukasz/docker-scala:latest

RUN  apt-get install net-tools

RUN git clone https://github.com/xperi/mqttd.git /opt/akka-mqttd

WORKDIR /opt/akka-mqttd

RUN sbt compile

CMD ["sbt", "run"]

EXPOSE 8080
EXPOSE 1883
EXPOSE 30000