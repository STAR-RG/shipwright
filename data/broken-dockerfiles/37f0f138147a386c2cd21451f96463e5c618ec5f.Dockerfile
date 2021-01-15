FROM openjdk
MAINTAINER Roc Boronat <roc@fewlaps.com>
RUN mkdir superpi
WORKDIR superpi
RUN wget https://github.com/Fewlaps/superpi/releases/download/v1.0.0/superpi-1.0.jar
RUN chmod +x superpi-1.0.jar
ENTRYPOINT ["/usr/bin/java", "-jar", "superpi-1.0.jar"]
