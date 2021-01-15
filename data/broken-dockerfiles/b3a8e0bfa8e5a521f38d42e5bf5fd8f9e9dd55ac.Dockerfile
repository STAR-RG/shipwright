FROM phusion/baseimage:0.9.18

MAINTAINER hbokh

RUN apt-get update -qq && \
    apt-get install -qqy software-properties-common python-software-properties && \
    apt-add-repository ppa:webupd8team/java -y && \
    apt-get update -qq && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Jira
COPY install-jira.sh /root/install-jira.sh
RUN /root/install-jira.sh

# Launching Jira
# And add start script in my_init.d of Phusion baseimage
WORKDIR /opt/jira-home
RUN rm -f /opt/jira-home/.jira-home.lock && mkdir -p /etc/my_init.d
COPY ./start-jira.sh /etc/my_init.d/start-jira.sh

EXPOSE 8080

CMD  ["/sbin/my_init"]
