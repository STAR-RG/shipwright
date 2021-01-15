FROM azul/zulu-openjdk:8
MAINTAINER Greg Bakos <znurgl@gmail.com>

RUN \
	echo "deb http://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list && \
	sudo apt-get update && \
	sudo apt-get -y --force-yes install sbt

EXPOSE 9000

WORKDIR /src
CMD ["sbt", "run"]
