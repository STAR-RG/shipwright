FROM rigormortiz/ubuntu-xrdp:0.1

MAINTAINER Mike Ortiz <mike@jellydice.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y && \
    apt-get install -y mate-core \
    mate-desktop-environment mate-notification-daemon \
    gconf-service libnspr4 libnss3 fonts-liberation \
    libappindicator1 libcurl3 fonts-wqy-microhei firefox && \
    apt-get autoclean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "mate-session" > /home/desktop/.xsession
