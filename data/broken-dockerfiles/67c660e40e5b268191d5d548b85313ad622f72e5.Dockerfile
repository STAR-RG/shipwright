FROM vtajzich/mesos-java8-docker:0.23.0
MAINTAINER Vitek Tajzich <vtajzich@vendavo.com>

ENV YOWIE_VERSION 0.1.5

RUN mkdir /home/yowie
WORKDIR /home/yowie

ADD https://bintray.com/artifact/download/vendavo/maven/com/vendavo/mesos/yowie/yowie-framework/${YOWIE_VERSION}/yowie-framework-${YOWIE_VERSION}.tar /home/yowie/
RUN tar -xvf yowie-framework-${YOWIE_VERSION}.tar && rm yowie-framework-${YOWIE_VERSION}.tar

EXPOSE 8080 

CMD /home/yowie/yowie-framework-${YOWIE_VERSION}/bin/yowie-framework
