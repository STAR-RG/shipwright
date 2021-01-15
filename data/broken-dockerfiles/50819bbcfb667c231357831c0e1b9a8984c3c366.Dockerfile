FROM centos:7


COPY ./* /tmp/


RUN yum install -y net-tools && yum install -y fontconfig && yum install -y freetype && yum install -y libXfont && yum install -y mesa-libGL && yum install -y mesa-libGLU && yum install -y Xvfb 


ADD . /src

RUN /usr/sbin/useradd --create-home --home-dir /usr/local/arcgis --shell /bin/bash arcgis 

RUN chown -R arcgis /src

USER arcgis

ENV HOME /usr/local/arcgis

RUN tar xvzf /tmp/ArcGIS_for_Server_Linux_1031_145870.gz -C /tmp/ && /tmp/ArcGISServer/Setup -m silent -l yes -a /tmp/authorization.ecp

EXPOSE 1098 4000 4001 4002 4003 4004 6006 6080 6099 6443
