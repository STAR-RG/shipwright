FROM quay.io/ukhomeofficedigital/centos-base:v0.5.6

RUN yum install -y wget &&  wget http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm 
RUN rpm -ivh epel-release-7-11.noarch.rpm

RUN yum install -y -q python-pip java-1.8.0-openjdk-devel fontconfig dejavu-sans-fonts git parallel which; yum clean all; pip install awscli

# Install jenkins
ENV JENKINS_VERSION 2.64
RUN yum install -y -q http://pkg.jenkins-ci.org/redhat/jenkins-${JENKINS_VERSION}-1.1.noarch.rpm

ENV DOCKER_VERSION 17.04.0-ce
RUN curl -s https://howtowhale.github.io/dvm/downloads/latest/install.sh | sh && \ 
source /root/.dvm/dvm.sh && \  
dvm install ${DOCKER_VERSION}

RUN echo source /root/.dvm/dvm.sh >> /root/.bashrc && echo dvm install ${DOCKER_VERSION} >> /root/.bashrc

# Install kubectl
ENV KUBE_VER=1.6.3
ENV KUBE_URL=https://storage.googleapis.com/kubernetes-release/release/v${KUBE_VER}/bin/linux/amd64/kubectl
RUN /bin/bash -l -c "wget --quiet ${KUBE_URL} \
                     -O /usr/local/bin/kubectl && \
                     chmod +x /usr/local/bin/kubectl"

# Install S3 Secrets
RUN /usr/bin/mkdir -p /opt/bin
RUN URL=https://github.com/UKHomeOffice/s3secrets/releases/download/v0.1.3/s3secrets_v0.1.3_linux_x86_64 OUTPUT_FILE=/opt/bin/s3secrets MD5SUM=ec5bc16e6686c365d2ca753d31d62fd5 /usr/bin/bash -c 'until [[ -x ${OUTPUT_FILE} ]] && [[ $(md5sum ${OUTPUT_FILE} | cut -f1 -d" ") == ${MD5SUM} ]]; do wget -q -O ${OUTPUT_FILE} ${URL} && chmod +x ${OUTPUT_FILE}; done'

# Install docker-compose
RUN URL=https://github.com/docker/compose/releases/download/1.13.0/docker-compose-Linux-x86_64 OUTPUT_FILE=/usr/local/bin/docker-compose MD5SUM=13196d9b1c3f3be0964b7536c39348b5 /usr/bin/bash -c 'until [[ -x ${OUTPUT_FILE} ]] && [[ $(md5sum ${OUTPUT_FILE} | cut -f1 -d" ") == ${MD5SUM} ]]; do wget -q -O ${OUTPUT_FILE} ${URL} && chmod +x ${OUTPUT_FILE}; done'

ENV JENKINS_HOME /opt/jenkins

ADD jenkins.sh /srv/jenkins/jenkins.sh
ADD jenkins_backup.sh /srv/jenkins/jenkins_backup.sh

# User config / updates
# JENKINS_UC is needed to download plugins
ENV JENKINS_UC https://updates.jenkins.io
COPY plugins.sh /usr/local/bin/plugins.sh
COPY plugins.base.txt /usr/share/jenkins/ref/
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.base.txt
COPY plugins.txt /usr/share/jenkins/ref/
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt

EXPOSE 8080
VOLUME /opt/jenkins
WORKDIR /opt/jenkins

ENTRYPOINT ["/srv/jenkins/jenkins.sh"]

