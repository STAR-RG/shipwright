#
#
#
FROM ubuntu:15.10
MAINTAINER Jonas Jongejan "jonas@halfdanj.dk"

ENV OF_VERSION 0.9.3

RUN apt-get update && apt-get install -y wget apt-utils

RUN wget http://openframeworks.cc/versions/v${OF_VERSION}/of_v${OF_VERSION}_linux64_release.tar.gz
RUN tar -xzvf /of_v${OF_VERSION}_linux64_release.tar.gz
RUN mv /of_v${OF_VERSION}_linux64_release /openFrameworks

RUN cd /openFrameworks/scripts/linux/ubuntu/; ./install_dependencies.sh -y
#RUN cd /openFrameworks/scripts/linux/ubuntu/; ./install_codecs.sh

RUN apt-get install  libmpg123-dev gstreamer1.0 gstreamer1.0-plugins-ugly -y

RUN cd /openFrameworks/scripts/linux/; ./compileOF.sh -j3

RUN mkdir /openFrameworks/apps/myApps/app/; ln -s /openFrameworks/apps/myApps/app/ /app

WORKDIR /openFrameworks/apps/myApps/app
CMD make -j4; make RunRelease
