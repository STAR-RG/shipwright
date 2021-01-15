# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
#
# jenkins-packer-agent
#
# VERSION   0.0.1

FROM debian:jessie

MAINTAINER Evan Brown <evanbrown@google.com>

# Update/upgrade apt
RUN apt-get update -y && apt-get upgrade -y

# Install supervisord and Java
RUN apt-get install -y supervisor default-jre
VOLUME /var/log/supervisor

# Install Packer
RUN apt-get install -y unzip curl git
RUN curl -L https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_linux_amd64.zip -o /tmp/packer.zip; unzip /tmp/packer.zip -d /usr/local/bin

# Install Jenkins Swarm agent
ENV HOME /home/jenkins-agent
RUN useradd -c "Jenkins agent" -d $HOME -m jenkins-agent
RUN curl --create-dirs -sSLo \
    /usr/share/jenkins/swarm-client-jar-with-dependencies.jar \
    http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/2.0/swarm-client-2.0-jar-with-dependencies.jar \
    && chmod 755 /usr/share/jenkins

# Install gcloud
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
RUN apt-get install -y -qq --no-install-recommends wget unzip python php5-mysql php5-cli php5-cgi openjdk-7-jre-headless openssh-client python-openssl \
  && apt-get clean \
  && cd /home/jenkins-agent \
  && wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip && unzip google-cloud-sdk.zip && rm google-cloud-sdk.zip \
  && google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --disable-installation-options \
  && google-cloud-sdk/bin/gcloud --quiet components update pkg-go pkg-python pkg-java app \
  && google-cloud-sdk/bin/gcloud --quiet config set component_manager/disable_update_check true \
  && chown -R jenkins-agent /home/jenkins-agent/.config \
  && chown -R jenkins-agent google-cloud-sdk
ENV PATH /home/jenkins-agent/google-cloud-sdk/bin:$PATH

# Run Docker and Swarm processe with supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY jenkins-docker-supervisor.sh /usr/local/bin/jenkins-docker-supervisor.sh
ENTRYPOINT ["/usr/local/bin/jenkins-docker-supervisor.sh"]
