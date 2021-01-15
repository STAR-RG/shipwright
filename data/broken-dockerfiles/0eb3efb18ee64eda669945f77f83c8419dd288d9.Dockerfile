FROM node:7
MAINTAINER Kirsten Hunter (khunter@akamai.com)
RUN apt-get update
RUN apt-get install -y curl patch gawk g++ gcc make libc6-dev patch libreadline6-dev zlib1g-dev libssl-dev libyaml-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev
RUN apt-get install -y -q libssl-dev python-all wget vim
ADD . /opt
WORKDIR /opt
RUN /usr/local/bin/npm install
RUN export PATH=${PATH}:/opt/bin
RUN git clone https://github.com/akamai-open/api-kickstart
RUN git clone https://github.com/stedolan/jq.git
RUN cp /opt/.bashrc /root/.bashrc
ENTRYPOINT ["/bin/bash"]
