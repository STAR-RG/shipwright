FROM debian:wheezy

RUN apt-get -q update
RUN apt-get -qy install \
    iptables \
    procps \
    psmisc \
    redsocks
    
ADD redsocks.conf /tmp/
ADD redsocks /root/

ENTRYPOINT ["/bin/bash", "/root/redsocks"]

