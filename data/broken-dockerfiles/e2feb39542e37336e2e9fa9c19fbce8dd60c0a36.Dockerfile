FROM yajo/centos-epel:latest

#FROM centos:latest
#RUN rpm -ivh http://build.openhpc.community/OpenHPC:/1.1/CentOS_7.2/x86_64/ohpc-release-1.1-1.x86_64.rpm
#RUN yum -y groupinstall ohpc-base
#RUN yum -y groupinstall ohpc-slurm-server
RUN yum -y install clustershell
RUN yum -y install supervisor
RUN yum -y install man mariadb mariadb-devel gcc gcc-g++ make munge munge-devel bzip2 vim-minimal tar curl perl
# Configure munge RUN create-munge-key
WORKDIR /opt
#RUN wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
#RUN rpm -ivh epel-release-7-8.noarch.rpm

RUN curl -OfsL http://www.schedmd.com/download/total/slurm-16.05.4.tar.bz2
RUN bzip2 -dc slurm-16.05.4.tar.bz2 | tar xvf -
WORKDIR /opt/slurm-16.05.4
RUN ./configure
RUN make
RUN make install
RUN useradd slurm
RUN yum -y install openssh openssh-server openssh-clients
RUN echo "root:root1234" | chpasswd
RUN useradd guest
RUN echo "guest:guest1234" | chpasswd
#RUN yum -y install clustershell
#RUN yum -y install supervisor

#ADD config /etc/ssh/ssh_config
ADD config /root/.ssh/config
ADD id_rsa /root/.ssh/id_rsa
ADD id_rsa.pub /root/.ssh/id_rsa.pub
ADD authorized_keys /root/.ssh/authorized_keys
RUN chmod -R 600 /root/.ssh/* && \
    chown -R root:root /root/.ssh
ADD slurm.conf /usr/local/etc/
ADD munge.key /etc/munge/

#CMD ["/usr/sbin/sshd", "-D"]
ADD deploy.sh /root/deploy.sh
RUN chmod +x /root/deploy.sh
RUN /usr/bin/ssh-keygen -A
EXPOSE 22
RUN chown root /run/munge
RUN chown root /etc/munge/munge.key
RUN chown root /var/lib/munge && \
    chown root /etc/munge && chmod 600 /var/run/munge && \
    chmod 755  /run/munge && \
    chmod 600 /etc/munge/munge.key
ADD supervisord.munged /etc/supervisord.d/munged.ini
ADD supervisord.sshd /etc/supervisord.d/sshd.ini
