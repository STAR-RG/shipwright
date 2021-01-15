FROM ubuntu:xenial

LABEL "Maintainer Chris Mosetick <cmosetick@gmail.com>"

ARG github_token

RUN \
sed -i 's@http://archive.ubuntu.com/ubuntu/@http://ubuntu.osuosl.org/ubuntu@g' /etc/apt/sources.list && \
apt-get update && \
apt-get -y install software-properties-common wget curl jq git iptables ca-certificates apparmor && \
add-apt-repository ppa:webupd8team/java -y && \
apt-get update

RUN \
(echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections) && \
apt-get install -y oracle-java8-installer oracle-java8-set-default

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV PATH $JAVA_HOME/bin:$PATH
ENV JENKINS_SWARM_VERSION 3.3
ENV HOME /home/jenkins-slave


RUN \
useradd -c "Jenkins Slave user" -d $HOME -m jenkins-slave && \
curl --create-dirs -sSLo $HOME/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/$JENKINS_SWARM_VERSION/swarm-client-$JENKINS_SWARM_VERSION-jar-with-dependencies.jar
COPY cmd.sh /cmd.sh

# setup our local files first
COPY docker-wrapper.sh /usr/local/bin/docker-wrapper
RUN chmod +x /usr/local/bin/docker-wrapper
# Always install latest version of Rancher CLI using Github API call in bash script
# pass in --build-arg github_token=<token> to make the download authenticated
COPY rancher-cli-download.sh /usr/local/bin/rancher-cli-download.sh


# now we install docker in docker - thanks to https://github.com/jpetazzo/dind
# We install newest docker into our docker in docker container
RUN \
curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz && \
tar --strip-components=1 -xvzf docker-latest.tgz -C /usr/local/bin && \
chmod +x /usr/local/bin/docker

RUN \
/usr/local/bin/rancher-cli-download.sh && \
tar xvf rancher-linux-amd64* && \
cp rancher-v*/rancher /usr/local/bin && \
chmod +x /usr/local/bin/rancher && \
rm -rf /var/cache/apt/*

VOLUME /var/lib/docker

#ENV JENKINS_USERNAME jenkins
#ENV JENKINS_PASSWORD jenkins
#ENV JENKINS_MASTER http://jenkins:8080

ENTRYPOINT ["/usr/local/bin/docker-wrapper"]
CMD /bin/bash /cmd.sh
