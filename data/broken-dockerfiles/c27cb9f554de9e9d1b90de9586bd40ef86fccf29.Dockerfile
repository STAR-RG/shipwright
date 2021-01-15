FROM centos:6

WORKDIR /opt
#VOLUME . /opt
RUN bash /opt/scripts/cent6_setup.sh
RUN cp /opt/dist/* /tmp/results
