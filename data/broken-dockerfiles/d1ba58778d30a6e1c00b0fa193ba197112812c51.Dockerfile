FROM 192.168.1.139:5003/jfrog/artifactory-registry:latest

MAINTAINER Mark Galpin markg@jfrog.com

ADD assets/artifactory.lic /var/opt/jfrog/artifactory/etc/artifactory.lic
ADD artifactory-user-plugins/docker/dockerRetag/dockerRetag.groovy /var/opt/jfrog/artifactory/etc/plugins/
ADD artifactory-user-plugins/build/promoteWithDeps/promoteWithDeps.groovy /var/opt/jfrog/artifactory/etc/plugins/
RUN /bin/bash -c cd ~artifactory; chown artifactory:artifactory /var/opt/jfrog/artifactory/etc/plugins

CMD /tmp/run.sh
