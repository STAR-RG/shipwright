# This file creates a container that runs X11 and SSH services
# The ssh is used to forward X11 and provide you encrypted data
# communication between the docker container and your local 
# machine.
#
# Xpra allows to display the programs running inside of the
# container such as Firefox, LibreOffice, xterm, etc. 
# with disconnection and reconnection capabilities
#
# The applications are rootless, therefore the client machine 
# manages the windows displayed.
# 
# ROX-Filer creates a very minimalist way to manage 
# files and icons on the desktop. 
#
# Author: Paul Czarkowski
# Date: 07/12/2013
# Based on :- https://github.com/rogaha/docker-desktop


FROM paulczar/logstash
MAINTAINER Paul Czarkowski "paul@paulcz.net"

RUN apt-get -y install zip

# Copy the files into the container
ADD . /logstash

ADD http://www.splunk.com/base/images/Tutorial/Sampledata.zip /logstash/sample.zip

RUN unzip /logstash/sample.zip -d /logstash/

EXPOSE 514
EXPOSE 515

# Start logstash
CMD ["/usr/bin/java", "-jar", "/opt/logstash/bin/logstash-1.1.13-flatjar.jar", "agent", "-f", "/logstash/logstash.conf", "-v"]

