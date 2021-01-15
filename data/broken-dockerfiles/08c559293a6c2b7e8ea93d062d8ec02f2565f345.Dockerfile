FROM centos:latest
MAINTAINER Paul Cuzner <pcuzner@redhat.com> 
ENV container docker

#RUN yum -y update
RUN curl -o /etc/yum.repos.d/glusterfs-epel.repo \
    http://download.gluster.org/pub/gluster/glusterfs/3.7/LATEST/CentOS/glusterfs-epel.repo

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm 

#RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs

RUN yum --setopt=tsflags=nodocs -y install xfsprogs nfs-utils nmap-ncat \
    openssh-server openssh-clients attr iputils iproute net-tools \
    glusterfs glusterfs-server glusterfs-fuse glusterfs-geo-replication \
    glusterfs-cli glusterfs-api && yum clean all -y

VOLUME [ "/sys/fs/cgroup" ]

RUN systemctl enable glusterd.service sshd.service

RUN mkdir -p /build/config/{etc/glusterfs,var/lib/glusterd,var/log/glusterfs}

RUN cp -pr /etc/glusterfs/* /build/config/etc/glusterfs && \
    cp -pr /var/lib/glusterd/* /build/config/var/lib/glusterd && \
    cp -pr /var/log/glusterfs/* /build/config/var/log/glusterfs

ADD entrypoint.sh /build/entrypoint.sh
ADD utils.sh /build/utils.sh
ADD create_cluster.sh /build/create_cluster.sh

RUN echo "root:password" | chpasswd

EXPOSE 22 111 245 443 24007 2049 8080 6010 6011 6012 38465 38466 38468 \
       38469 49152 49153 49154 49156 49157 49158 49159 49160 49161 49162
       
ENTRYPOINT ["/build/entrypoint.sh"]

