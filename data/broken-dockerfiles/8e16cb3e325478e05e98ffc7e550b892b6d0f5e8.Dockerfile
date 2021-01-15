# Ocserv-rp 
FROM ubuntu:trusty 
MAINTAINER rp <rphoho@gmail.com>

# Move local file to container
ADD ./bin /usr/local/bin
ADD ./certs /opt/certs
ADD ./ocserv /etc/ocserv
RUN chmod a+x /usr/local/bin/*

# Install all required library
RUN apt-get update
RUN apt-get install build-essential libwrap0-dev libpam0g-dev libdbus-1-dev libreadline-dev libnl-route-3-dev  libpcl1-dev libopts25-dev autogen libgnutls28 libgnutls28-dev libseccomp-dev iptables wget gnutls-bin libprotobuf-c0-dev protobuf-c-compiler libprotobuf-dev protobuf-compiler libprotoc-dev libtalloc-dev libhttp-parser-dev tcl tk expect -y

# Install the ocserv latest version
RUN cd /root && wget http://www.infradead.org/ocserv/download.html && export ocserv_version=$(cat download.html | grep -o '[0-9]\.[0-9]\.[0-9]') \
    && wget ftp://ftp.infradead.org/pub/ocserv/ocserv-$ocserv_version.tar.xz && tar xvf ocserv-$ocserv_version.tar.xz \
    && cd ocserv-$ocserv_version && ./configure --prefix=/usr --sysconfdir=/etc && make && make install \
    && rm -rf /root/download.html && rm -rf ocserv-*

# Gernerate the CA and a local server certificate
RUN certtool --generate-privkey --outfile /opt/certs/ca-key.pem \
    && certtool --generate-self-signed --load-privkey /opt/certs/ca-key.pem --template /opt/certs/ca.tmpl --outfile /opt/certs/ca-cert.pem \
    && certtool --generate-privkey --outfile /opt/certs/server-key.pem \
    && certtool --generate-certificate --load-privkey /opt/certs/server-key.pem --load-ca-certificate /opt/certs/ca-cert.pem --load-ca-privkey /opt/certs/ca-key.pem --template /opt/certs/server.tmpl --outfile /opt/certs/server-cert.pem

# Set user and password for the VPN
RUN user-init

# Initialize the Ocserv VPN
CMD ["ocserv-run"]
