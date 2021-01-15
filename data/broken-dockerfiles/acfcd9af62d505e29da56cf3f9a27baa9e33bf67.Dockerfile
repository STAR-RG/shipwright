# Building this image from VMware Photon OS TP2

FROM vmware/photon:tp2
MAINTAINER Pravin Goyal <pgoyal@vmware.com>
LABEL Description="This image is used for STIG Compliance."

# Install yum
RUN tdnf -y install yum

# Install libraries and required components
RUN yum -y install apache-tomcat \
autoconf \
automake \
binutils \
bzip2-devel \
cmake \
diffutils \
gawk \
gcc \
glibc-devel \
gmp-devel \
gzip \
libacl-devel \
libcap-devel \
libgcc-devel \
libgcrypt-devel \
libgomp-devel \
libselinux-devel \
libsigc++ \
libstdc++-devel \
libxml2-devel \
libxslt \
libxslt-devel \
linux-api-headers \
lzo-devel \
make \
mpfr-devel \
openjdk \
openssh \
openssl-devel \
pcre-devel \
popt-devel \
procps-ng-devel \
pycurl \
python2-devel \
python2-tools \
python-cryptography \
python-curses \
python-hawkey \
python-iniparse \
python-lxml \
python-pycparser \
rpm-build \
rpm-devel \
sed-lang \
sshpass \
sudo \
swig \
tar \
util-linux-devel \
util-linux-lang \
wget \
xml-security-c-devel \
xz-devel \
zlib-devel && yum clean all

# Install pip, ansible and the required packages
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py && rm -f get-pip.py
RUN pip install paramiko PyYAML Jinja2 httplib2 six ansible

# Install openSCAP 1.2.8
WORKDIR /tmp
RUN wget https://fedorahosted.org/releases/o/p/openscap/openscap-1.2.8.tar.gz && \
    gunzip openscap-1.2.8.tar.gz && \
    tar -xvf openscap-1.2.8.tar && \
    rm -f openscap-1.2.8.tar

WORKDIR /tmp/openscap-1.2.8
RUN ./configure --prefix=/usr && make && make install

WORKDIR /
RUN rm -rf /tmp/openscap-1.2.8

# Creating tomcat user
RUN groupadd tomcat
RUN useradd -G tomcat tomcat

# oscap commands require root privileges. Web service runs as tomcat. Hence need sudo package and its configuration.
RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "Defaults env_keep += SSH_AUTH_SOCK" >> /etc/sudoers
RUN usermod -G wheel tomcat

# Creating directories where SCAP content, Assessment Results, Assessment Logs, Assessment Scripts and Temporary Files would be placed.
RUN mkdir -p /usr/share/xml/stig-compliance/content
RUN mkdir -p /usr/share/xml/stig-compliance/results
RUN mkdir -p /usr/share/xml/stig-compliance/logs
RUN mkdir -p /usr/share/xml/stig-compliance/scripts
RUN mkdir -p /usr/share/xml/stig-compliance/temp

# Placing some sample SCAP content for SLES OS
COPY file_test_content-ds.xml /usr/share/xml/stig-compliance/content/
COPY sles11-ds.xml /usr/share/xml/stig-compliance/content/

# Putting the VMware branding file
COPY xccdf-branding.xsl /usr/share/openscap/xsl/

# Copy Scripts, XSL file to extract fixes, and tomcat web service related files
COPY assess.sh /usr/share/xml/stig-compliance/scripts/
RUN  chmod 755 /usr/share/xml/stig-compliance/scripts/assess.sh

COPY assess_oval.sh /usr/share/xml/stig-compliance/scripts/
RUN  chmod 755 /usr/share/xml/stig-compliance/scripts/assess_oval.sh

COPY assess_passwordless.sh /usr/share/xml/stig-compliance/scripts/
RUN  chmod 755 /usr/share/xml/stig-compliance/scripts/assess_passwordless.sh

COPY assess_oval_passwordless.sh /usr/share/xml/stig-compliance/scripts/
RUN  chmod 755 /usr/share/xml/stig-compliance/scripts/assess_oval_passwordless.sh

COPY compare.py /usr/share/xml/stig-compliance/scripts/
RUN  chmod 755 /usr/share/xml/stig-compliance/scripts/compare.py

COPY assess_dev.sh /usr/share/xml/stig-compliance/scripts/
RUN  chmod 755 /usr/share/xml/stig-compliance/scripts/assess_dev.sh

COPY fix.sh /usr/share/xml/stig-compliance/scripts/
RUN  chmod 755 /usr/share/xml/stig-compliance/scripts/fix.sh

COPY fix_passwordless.sh /usr/share/xml/stig-compliance/scripts/
RUN  chmod 755 /usr/share/xml/stig-compliance/scripts/fix_passwordless.sh

COPY harden.sh /usr/share/xml/stig-compliance/scripts/
RUN  chmod 755 /usr/share/xml/stig-compliance/scripts/harden.sh

COPY harden_passwordless.sh /usr/share/xml/stig-compliance/scripts/
RUN  chmod 755 /usr/share/xml/stig-compliance/scripts/harden_passwordless.sh

COPY view_playbook.sh /usr/share/xml/stig-compliance/scripts/
RUN  chmod 755 /usr/share/xml/stig-compliance/scripts/view_playbook.sh

COPY getfixes.xsl /usr/share/xml/stig-compliance/scripts/
COPY filterresults.xsl /usr/share/xml/stig-compliance/scripts/
COPY filtertitle.xsl /usr/share/xml/stig-compliance/scripts/
COPY ruleidresult.xsl /usr/share/xml/stig-compliance/scripts/
COPY stig.war /var/opt/apache-tomcat-7.0.63/webapps/
COPY index.html /var/opt/apache-tomcat-7.0.63/webapps/ROOT/
COPY favicon.ico /var/opt/apache-tomcat-7.0.63/webapps/ROOT/

ADD  gold.sh /usr/local/bin/gold
RUN  chmod 755 /usr/local/bin/gold

RUN  mkdir -p /var/opt/apache-tomcat-7.0.63/temp

# Setting up ownership for tomcat to be able to read and write to the directories
RUN chown -R tomcat:tomcat /usr/share/xml/stig-compliance
RUN chown -R tomcat:tomcat /var/opt/apache-tomcat-7.0.63


# Setting up tomcat environment variables
RUN su - tomcat
ENV CATALINA_BASE=/var/opt/apache-tomcat-7.0.63/
ENV CATALINA_HOME=/var/opt/apache-tomcat-7.0.63/
ENV CATALINA_TMPDIR=/var/opt/apache-tomcat-7.0.63/temp
ENV JAVA_HOME=/opt/OpenJDK-1.8.0.51-bin

## Setup TLS
#  Generate key
RUN sudo /opt/OpenJDK-1.8.0.51-bin/bin/keytool -genkey \
    -keyalg RSA \
    -keystore /var/opt/apache-tomcat-7.0.63/.keystore \
    -dname "cn=VMware-STIG-Compliance, ou=IT, o=VMware, c=US" \
    -storepass password -keypass password

# Setup TLS configuration in Tomcat server configuration file
RUN sed -i "s#</Server>##g" /var/opt/apache-tomcat-7.0.63/conf/server.xml; \
	sed -i "s#  </Service>##g" /var/opt/apache-tomcat-7.0.63/conf/server.xml; \
	echo '    <Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true" maxThreads="150" scheme="https" secure="true" clientAuth="false" sslProtocol="TLS" keystoreFile="/var/opt/apache-tomcat-7.0.63/.keystore" keystorePass="password" />' >> /var/opt/apache-tomcat-7.0.63/conf/server.xml; \
	echo '  </Service>' >> /var/opt/apache-tomcat-7.0.63/conf/server.xml; \
	echo '</Server>' >> /var/opt/apache-tomcat-7.0.63/conf/server.xml

# Setting working directory for web service
WORKDIR /var/opt/apache-tomcat-7.0.63/bin

# Container should run as tomcat user by default and not root
USER tomcat

# Making the container executable so that user just needs to do
# docker run -d -p [host-port]:[container-port] [container-image]
# docker run -d -p 443:8443 praving5/stig-compliance
ENTRYPOINT sh catalina.sh run

# Copying Opensource license
COPY open_source_license_GOLD_vApp_STIG_Assessment_and_Remediation_Tool_1.0.0_TP.txt /usr/share/xml/stig-compliance/
