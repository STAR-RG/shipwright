# Sentry environment for CentOS 6.x
#
# VERSION       0.0.1

FROM centos
MAINTAINER Kentaro Yoshida "https://github.com/y-ken"

# Configure ENV
ENV HOME /root

# Setup timezone
RUN echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock
RUN echo 'UTC="false"' >> /etc/sysconfig/clock
RUN echo 'ARC="false"' >> /etc/sysconfig/clock
RUN cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime 

# This file is needed in /etc/init.d/mysqld
RUN touch /etc/sysconfig/network

# Setup Sentry
RUN mkdir /usr/local/src/sentry
ADD setup_sentry.sh /usr/local/src/sentry/setup_sentry.sh
ADD sentry.conf.py.patch /usr/local/src/sentry/sentry.conf.py.patch
ADD supervisord_sentry.conf /usr/local/src/sentry/supervisord_sentry.conf
ADD supervisord_docker.conf /usr/local/src/sentry/supervisord_docker.conf
WORKDIR /usr/local/src/sentry
RUN sh /usr/local/src/sentry/setup_sentry.sh

# Setup sshd to accept login
RUN yum -y install openssh-server
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN bash -c 'echo "root:root" | chpasswd'
RUN /etc/init.d/sshd start
RUN /etc/init.d/sshd stop

# Set default `docker run` command behavior
RUN sed -i 's/nodaemon=false/nodaemon=true/' /etc/supervisord.conf
RUN cat /usr/local/src/sentry/supervisord_docker.conf >> /etc/supervisord.conf

EXPOSE 22
EXPOSE 9000
CMD ["/usr/bin/supervisord"]
