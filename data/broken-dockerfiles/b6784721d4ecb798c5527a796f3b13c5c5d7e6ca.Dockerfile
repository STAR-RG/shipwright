FROM ubuntu:precise
MAINTAINER Martin Gondermann magicmonty@pagansoft.de

ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list && \
	apt-get update && \
	apt-get -y upgrade && \
	apt-get -y install curl unzip && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Create data directories
RUN mkdir -p /data/mysql /data/www

RUN curl -G -o /data/joomla.zip http://joomlacode.org/gf/download/frsrelease/19239/158104/Joomla_3.2.3-Stable-Full_Package.zip && \
	unzip /data/joomla.zip -d /data/www && \
	rm /data/joomla.zip

# Create /data volume
VOLUME ["/data"]

CMD /bin/sh

# MariaDB (https://mariadb.org/)
FROM ubuntu:trusty
MAINTAINER Martin Gondermann magicmonty@pagansoft.de

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get -y -q install wget logrotate

# Ensure UTF-8
RUN apt-get update
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Install MariaDB from repository.
RUN 	apt-get update && \
	apt-get install -y mariadb-server

# Decouple our data from our container.
VOLUME ["/data"]

# Configure the database to use our data dir.
RUN sed -i -e 's/^datadir\s*=.*/datadir = \/data\/mysql/' /etc/mysql/my.cnf

# Configure MariaDB to listen on any address.
RUN sed -i -e 's/^bind-address/#bind-address/' /etc/mysql/my.cnf
EXPOSE 3306
ADD site-db/start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]

FROM ubuntu:precise
MAINTAINER magicmonty@pagansoft.de

# Install all that’s needed
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list && \
	apt-get update && \
	apt-get -y upgrade && \
	apt-get -y install mysql-client apache2 libapache2-mod-php5 pwgen python-setuptools vim-tiny php5-mysql openssh-server sudo php5-ldap unzip && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*
RUN easy_install supervisor

# Add all config and start files
ADD web-machine/start.sh /start.sh
ADD web-machine/foreground.sh /etc/apache2/foreground.sh
ADD web-machine/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /var/log/supervisord /var/run/sshd
RUN chmod 755 /start.sh && chmod 755 /etc/apache2/foreground.sh

# Set Apache user and log
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2

VOLUME ["/data"]

# Add site to apache
ADD web-machine/joomla /etc/apache2/sites-available/
RUN a2ensite joomla
RUN a2dissite 000-default

# Set root password to access through ssh
RUN echo "root:desdemona" | chpasswd

# Expose web and ssh
EXPOSE 80
EXPOSE 22

CMD ["/bin/bash", "/start.sh"]
