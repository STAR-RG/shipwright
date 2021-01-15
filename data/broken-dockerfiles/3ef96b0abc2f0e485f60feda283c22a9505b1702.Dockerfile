FROM ubuntu:18.04

MAINTAINER Rory McCune <rorym@mccune.org.uk>

WORKDIR /opt/

#Localtime hack
COPY localtime /etc/localtime

#General packages and pre-reqs for tools like Metasploit
RUN apt-get update && apt-get install -y \
	build-essential \
	git-core \
	subversion \
	vim \
	wget \
	smbclient \
	nfs-common \
	rsh-client \
	whois \
	snmp \
	libreadline-dev \
	libpq5 \
	libpq-dev \
	libreadline5 \
	libsqlite3-dev \
	libpcap-dev \
	autoconf \
	postgresql \
	pgadmin3 \
	curl \
	zlib1g-dev \
	libxml2-dev \
	libxslt1-dev \
	libyaml-dev \
	ssh \
	slurm \
	curl \
	libssl-dev \
	ruby \
	net-tools \
	ruby-dev

RUN gem install bundler -v '1.17.3'

#Install nmap
RUN git clone --depth=1 https://github.com/nmap/nmap.git && \
	cd nmap && \
	./configure --without-zenmap && \
	make && \
	make install && \
	rm -rf ../nmap

RUN gem install bundler

#Install Metasploit
RUN git clone --depth=1 https://github.com/rapid7/metasploit-framework.git && \
	cd metasploit-framework && \
	bundle install 

#Install Testing Scripts
RUN git clone --depth=1 https://github.com/raesene/TestingScripts.git && \
	cd TestingScripts && \
	bundle install


#Install Nikto Pre-reqs
RUN apt-get install -y \
	libnet-ssleay-perl

#Install Nikto
RUN git clone --depth=1 https://github.com/sullo/nikto.git && \
	cd nikto/program && \
	./nikto.pl -update

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

#We can run this but lets let it be overridden with a CMD 
CMD ["/entrypoint.sh"]
