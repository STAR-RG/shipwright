#
#  Dockerfile for a GPDB SNE Sandbox Base Image
#

FROM centos:6.7
MAINTAINER dbaskette@pivotal.io

COPY * /tmp/
RUN echo root:pivotal | chpasswd \
        && yum install -y unzip which tar more util-linux-ng passwd openssh-clients openssh-server ed m4; yum clean all \
        && unzip /tmp/greenplum-db-4.3.7.1-build-1-RHEL5-x86_64.zip -d /tmp/ \
        && rm /tmp/greenplum-db-4.3.7.1-build-1-RHEL5-x86_64.zip \
        && sed -i s/"more << EOF"/"cat << EOF"/g /tmp/greenplum-db-4.3.7.1-build-1-RHEL5-x86_64.bin \
        && echo -e "yes\n\nyes\nyes\n" | /tmp/greenplum-db-4.3.7.1-build-1-RHEL5-x86_64.bin \
        && rm /tmp/greenplum-db-4.3.7.1-build-1-RHEL5-x86_64.bin \
        && cat /tmp/sysctl.conf.add >> /etc/sysctl.conf \
        && cat /tmp/limits.conf.add >> /etc/security/limits.conf \
        && rm -f /tmp/*.add \
        && echo "localhost" > /tmp/gpdb-hosts \
        && chmod 777 /tmp/gpinitsystem_singlenode \
        && hostname > ~/orig_hostname \
        && mv /tmp/run.sh /usr/local/bin/run.sh \
        && chmod +x /usr/local/bin/run.sh \
        && /usr/sbin/groupadd gpadmin \
        && /usr/sbin/useradd gpadmin -g gpadmin -G wheel \
        && echo "pivotal"|passwd --stdin gpadmin \
        && echo "gpadmin        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers \
        && mv /tmp/bash_profile /home/gpadmin/.bash_profile \
        && chown -R gpadmin: /home/gpadmin \
        && mkdir -p /gpdata/master /gpdata/segments \
        && chown -R gpadmin: /gpdata \
        && chown -R gpadmin: /usr/local/green* \
        && service sshd start \
        && su gpadmin -l -c "source /usr/local/greenplum-db/greenplum_path.sh;gpssh-exkeys -f /tmp/gpdb-hosts"  \
        && su gpadmin -l -c "source /usr/local/greenplum-db/greenplum_path.sh;gpinitsystem -a -c  /tmp/gpinitsystem_singlenode -h /tmp/gpdb-hosts; exit 0 "\
        && su gpadmin -l -c "export MASTER_DATA_DIRECTORY=/gpdata/master/gpseg-1;source /usr/local/greenplum-db/greenplum_path.sh;psql -d template1 -c \"alter user gpadmin password 'pivotal'\"; createdb gpadmin;  exit 0"

EXPOSE 5432 22

VOLUME /gpdata
# Set the default command to run when starting the container

CMD echo "127.0.0.1 $(cat ~/orig_hostname)" >> /etc/hosts \
        && service sshd start \
#       && sysctl -p \
        && su gpadmin -l -c "/usr/local/bin/run.sh" \
        && /bin/bash
