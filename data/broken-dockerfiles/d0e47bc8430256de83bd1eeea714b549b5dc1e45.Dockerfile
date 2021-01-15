FROM hurricane/dockergui:xvnc
#FROM hurricane/dockergui:x11rdp
#FROM hurricane/dockergui:xvnc

MAINTAINER David Coppit <david@coppit.org>

ENV APP_NAME="HandBrake" WIDTH=1280 HEIGHT=720 TERM=xterm

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive
ADD dpkg-excludes /etc/dpkg/dpkg.cfg.d/excludes

RUN true && \

set -x && \

# Create dir to keep things tidy. Make sure it's readable by $USER_ID
mkdir /files && \
chmod a+rwX /files && \

# Speed up APT
echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \

# repositories
echo 'deb http://archive.ubuntu.com/ubuntu trusty main universe restricted' > /etc/apt/sources.list && \
echo 'deb http://archive.ubuntu.com/ubuntu trusty-updates main universe restricted' >> /etc/apt/sources.list && \
add-apt-repository ppa:stebbins/handbrake-releases && \

# Update apt and install dependencies.
apt-get update && \
apt-get install -qy handbrake-gtk=1.1.0-zhb-1ppa1~trusty1 handbrake-cli=1.1.0-zhb-1ppa1~trusty1 gnome-themes-standard=3.10.0-1ubuntu2 && \

# Install watchdog module for Python3, for monitor.py
apt-get install -qy python3-setuptools=3.3-1ubuntu2 && \
easy_install3 watchdog && \

# clean up
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
/usr/share/man /usr/share/groff /usr/share/info \
/usr/share/lintian /usr/share/linda /var/cache/man && \
(( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) && \
(( find /usr/share/doc -empty|xargs rmdir || true ))

VOLUME ["/media", "/watch", "/output", "/config"]

EXPOSE 3389 8080

# Set the locale, to support files that have non-ASCII characters
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN true && \

# Fix guacamole errors and warnings:
# SEVERE: The scratchDir you specified: /var/lib/tomcat7/work/Catalina/localhost/guacamole is unusable.
# SEVERE: Cannot find specified temporary folder at /tmp/tomcat7-tomcat7-tmp
# WARNING: Failed to create work directory [/var/lib/tomcat7/work/Catalina/localhost/_] for context []
mkdir -p /var/cache/tomcat7 /tmp/tomcat7-tomcat7-tmp /var/lib/tomcat7/work/Catalina/localhost && \
ln -s /var/lib/tomcat7/common /usr/share/tomcat7/common && \
ln -s /var/lib/tomcat7/server /usr/share/tomcat7/server && \
ln -s /var/lib/tomcat7/shared /usr/share/tomcat7/shared && \

# Revision-lock to a specific version to avoid any surprises.
wget -q -O /files/runas.sh \
  'https://raw.githubusercontent.com/coppit/docker-inotify-command/1d4b941873b670525fd159dcb9c01bb2570b0565/runas.sh' && \
chmod +x /files/runas.sh && \
wget -q -O /files/monitor.py \
  'https://raw.githubusercontent.com/coppit/docker-inotify-command/1401a636bbc9369141d0d32ac7b80c2bf7fcdbcb/monitor.py' && \
chmod +x /files/monitor.py

# Add local files
COPY convert.sh HandBrake.conf.default /files/

ADD 50_configure_handbrake.sh /etc/my_init.d/

RUN mkdir /etc/service/monitor
ADD monitor.sh /etc/service/monitor/run
RUN chmod +x /etc/service/monitor/run

RUN mkdir /etc/service/handbrake-ui
ADD startapp.sh /etc/service/handbrake-ui/run
RUN chmod +x /etc/service/handbrake-ui/run
