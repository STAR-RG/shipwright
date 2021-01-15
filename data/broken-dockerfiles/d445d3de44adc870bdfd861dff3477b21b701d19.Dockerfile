FROM ubuntu:12.04
MAINTAINER Dominic Böttger "http://inspirationlabs.com"
RUN cat /proc/mounts > /etc/mtab

# set user
ENV MYSQL_USER mysql
# define database directory for start-script
ENV DATADIR /var/lib/mysql

# Make apt and MariaDB happy with the docker environment
RUN echo "#!/bin/sh\nexit 101" >/usr/sbin/policy-rc.d
RUN chmod +x /usr/sbin/policy-rc.d
RUN cat /proc/mounts > /etc/mtab

# set installation parameters to prevent the installation script from asking
RUN echo "mariadb-server-5.5 mysql-server/root_password password $MYSQL_ROOT_PW" | debconf-set-selections
RUN echo "mariadb-server-5.5 mysql-server/root_password_again password $MYSQL_ROOT_PW" | debconf-set-selections

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe multiverse" > /etc/apt/sources.list
RUN apt-get -y install wget python-software-properties
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN add-apt-repository 'deb http://mirror2.hs-esslingen.de/mariadb/repo/5.5/ubuntu precise main'
RUN apt-get update

ADD dpkg_selection.conf /tmp/dpkg_selection.conf

RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server supervisor apache2 php5 php5-cli php5-gd php5-mysql php-pear sudo rsync git-core unzip mariadb-server syslog-ng

# allow access from any IP
RUN sed -i '/^bind-address*/ s/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf
RUN mkdir -p $DATADIR
RUN sed -i "/^datadir*/ s|=.*|= $DATADIR|" /etc/mysql/my.cnf

RUN pear channel-discover pear.drush.org
RUN pear install drush/drush
RUN pear install Console_Table

RUN mkdir /var/aegir

RUN mkdir /root/.ssh
RUN mkdir /var/run/sshd
# NOTE: change this key to your own
ADD authorized_keys /root/.ssh/authorized_keys
RUN chown root:root /root/.ssh/authorized_keys

ADD run.sh /
ADD create_db.sh /
Add solr_install.sh /
ADD supervisor.conf /opt/supervisor.conf
ADD aegir_install.sh /

EXPOSE 22
EXPOSE 80
EXPOSE 443
VOLUME ["/var/aegir","/var/log/apache2", "/var/lib/mysql", "/etc/mysql/conf.d", "/var/log/mysql"]
CMD ["/run.sh"]