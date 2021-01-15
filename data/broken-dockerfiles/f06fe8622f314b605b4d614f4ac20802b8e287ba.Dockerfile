#
# ForgeRock OpenDJ
# 
FROM java:latest
MAINTAINER G. Hussain Chinoy <ghchinoy@gmail.com>

WORKDIR /opt

RUN apt-get install -y wget unzip

RUN wget --quiet http://download.forgerock.org/downloads/opendj/nightly/20150813_0017/OpenDJ-3.0.0-20150813.zip && unzip OpenDJ-3.0.0-20150813.zip && rm -r OpenDJ-3.0.0-20150813.zip 
RUN wget http://opendj.forgerock.org/Example.ldif -O /opt/Example.ldif

ENV INSTALLPROP opendj-install.properties
ENV STARTSH startOpenDJ

COPY $INSTALLPROP /opt/$INSTALLPROP
COPY startOpenDJ /opt/startOpenDJ
RUN chmod +x /opt/startOpenDJ

WORKDIR /opt/opendj

RUN ./setup --cli --propertiesFilePath /opt/$INSTALLPROP --acceptLicense --no-prompt

RUN ./bin/status

EXPOSE 1389

ENTRYPOINT ["/opt/startOpenDJ"]