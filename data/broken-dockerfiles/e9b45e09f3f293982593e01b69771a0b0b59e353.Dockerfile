# http://phusion.github.io/baseimage-docker/
FROM phusion/baseimage

# Use baseimage's init system.
CMD ["/sbin/my_init"]

# Set terminal to avoid harmless but unnecessary warnings
ENV TERM=xterm-256color

# Add source repository
ADD . /hermes

# Install Java 8 / Node / GCC / make
RUN add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) multiverse" && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y gcc && \
    apt-get install -y make && \
    apt-get install -y libpcre3-dev && \
    apt-get install -y nodejs && \
    apt-get install -y git && \

    # Accept Java license && Install
    echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \

    # Fix Ubuntu's broken Python 3 installation
    # Simplified from https://gist.github.com/uranusjr/d03a49767c7c307be5ed
    curl -L http://d.pr/f/YqS5+ | tar xvz -C /usr/lib/python3.4 && \

    # Clean up
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pyvenv-3.4 /hermes_venv
RUN ["/bin/bash", "-c", "/hermes/docker/install.sh /hermes /hermes_venv"]

# These next 4 commands are for enabling SSH to the container.
# id_rsa.pub is referenced below, but this should be any public key
# that you want to be added to authorized_keys for the root user.
# Copy the public key into this directory because ADD cannot reference
# Files outside of this directory

#EXPOSE 22
#RUN rm -f /etc/service/sshd/down
#ADD id_rsa.pub /tmp/id_rsa.pub
#RUN cat /tmp/id_rsa.pub >> /root/.ssh/authorized_keys
