FROM resin/rpi-raspbian
MAINTAINER pablo@resin.io

ENV DOCKER_HOST unix:///var/run/rce.sock
ENV FLANNEL_VERSION v0.4.1
ENV KUBERNETES_VERSION v0.18.1

# Install dependencies
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    rsync \
    build-essential \
    dropbear \
    net-tools \
    bridge-utils
    
# Install resin.io's rce (docker)
COPY ./rce /usr/bin/rce
RUN chmod u+x /usr/bin/rce
RUN ln -s /usr/bin/rce /usr/bin/docker

# Install kubernetes and flannel binaries
COPY ./hyperkube /hyperkube
COPY ./kubectl /kubectl
COPY ./flanneld /flanneld

RUN chmod +x /hyperkube
RUN chmod +x /kubectl
RUN chmod +x /flanneld

# Install the startup script.
ADD ./start.sh /usr/bin/start.sh
RUN chmod +x /usr/bin/start.sh

# Define additional metadata for our image.
VOLUME /var/lib/rce
RUN ln -s /var/lib/rce /var/lib/docker

CMD ["start.sh"]
