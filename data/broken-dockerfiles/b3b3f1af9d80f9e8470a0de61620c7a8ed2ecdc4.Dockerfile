# NO VNC
FROM ubuntu:18.04 as novnc

ENV DEBIAN_FRONTEND noninteractive

# Oracle Java
RUN apt-get update && apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN \
    echo debconf shared/accepted-oracle-license-v1-1 select true | \
        debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | \
        debconf-set-selections && \
    apt-get update && apt-get install -y \
        oracle-java8-installer

# digsign dependencies and firefox
RUN \
    apt-get update && apt-get install -y \
        bsdmainutils bc libnss3 \
        firefox

RUN \
    wget "https://edavki.durs.si/EdavkiPortal/%5B90007%5D/OpenPortal/Controls/ESignDocControls/digsighost.deb" \
        -O /tmp/digsighost.deb && \
    dpkg -i /tmp/digsighost.deb

COPY syspref.js /etc/firefox/syspref.js

CMD ["firefox"]


# VNC
FROM fredipevcin/edavki:novnc as vnc

RUN apt-get install -y x11vnc xvfb

RUN sh -c 'echo "firefox" >> ~/.bashrc'

CMD ["/usr/bin/x11vnc", "-forever", "-nopw", "-create"]