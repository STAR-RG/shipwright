FROM alpine/git
WORKDIR /app
RUN git clone https://github.com/Armando1514/P2P-Auction-Mechanism.git

FROM maven:3.5-jdk-8-alpine
WORKDIR /app
COPY --from=0 /app/P2P-Auction-Mechanism /app
RUN mvn package

FROM openjdk:8-jre-alpine
WORKDIR /app
ENV MASTERIP=127.0.0.1
ENV TIMEZONE=Europe/Rome
ENV ID=0
COPY --from=1 /app/target/P2P-auction-system-1.0-SNAPSHOT-jar-with-dependencies.jar /app
CMD /usr/bin/java -jar P2P-auction-system-1.0-SNAPSHOT-jar-with-dependencies.jar -m $MASTERIP -id $ID -tz $TIMEZONE