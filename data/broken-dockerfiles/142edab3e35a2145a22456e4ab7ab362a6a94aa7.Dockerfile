FROM centos:8
ARG project=minsky
ADD . /root
RUN yum install -y wget
RUN cd /etc/yum.repos.d/; wget https://download.opensuse.org/repositories/home:hpcoder1/CentOS_8/home:hpcoder1.repo
RUN yum install -y $project
RUN minsky /root/smoke.tcl

