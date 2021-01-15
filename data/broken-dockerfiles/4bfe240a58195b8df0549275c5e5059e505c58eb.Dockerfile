FROM quay.io/nordstrom/baseimage-ubuntu:16.04
MAINTAINER Innovation Platform Team "invcldtm@nordstrom.com"

USER root 

# Ensure there are enough file descriptors for running Fluentd.
RUN ulimit -n 65536

# Disable prompts from apt.
ENV DEBIAN_FRONTEND noninteractive

# Setup package for installing td-agent. (For more info https://td-toolbelt.herokuapp.com/sh/install-ubuntu-trusty-td-agent2.sh)
ADD https://packages.treasuredata.com/GPG-KEY-td-agent /tmp/apt-key
RUN apt-key add /tmp/apt-key
RUN echo "deb http://packages.treasuredata.com/2/ubuntu/trusty/ trusty contrib" > /etc/apt/sources.list.d/treasure-data.list

# Install prerequisites.
RUN apt-get update && \
    apt-get install -y -q curl make g++ && \
    apt-get clean && \
    apt-get install -y td-agent && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Change the default user and group to root.
# Needed to allow access to /var/log/docker/... files.
RUN sed -i -e "s/USER=td-agent/USER=root/" -e "s/GROUP=td-agent/GROUP=root/" /etc/init.d/td-agent

# Install the fluent-plugin-kubernetes_metadata_filter plug-in.
RUN /usr/sbin/td-agent-gem install fluent-plugin-kubernetes_metadata_filter -v 0.25.3 --no-ri --no-rdoc

# Install the aws-elasticsearch-service plugin (https://github.com/atomita/fluent-plugin-aws-elasticsearch-service).
RUN /usr/sbin/td-agent-gem install fluent-plugin-aws-elasticsearch-service -v 0.1.6 --no-ri --no-rdoc

# Install the systemd plugin (https://github.com/reevoo/fluent-plugin-systemd).
RUN /usr/sbin/td-agent-gem install fluent-plugin-systemd -v 0.0.4 --no-ri --no-rdoc

# Copy the Fluentd configuration file.
COPY td-agent.conf /etc/td-agent/td-agent.conf
COPY start-fluentd /start-fluentd
RUN chmod 766 /etc/td-agent/td-agent.conf && \
    chmod +x /start-fluentd

# Create directory for pos files and assign write permission to it
ENV POS_FILE_LOCATION /var/log
RUN mkdir -p ${POS_FILE_LOCATION}
RUN chmod 766 ${POS_FILE_LOCATION}

# Run the Fluentd service.
ENTRYPOINT ["/start-fluentd"]
