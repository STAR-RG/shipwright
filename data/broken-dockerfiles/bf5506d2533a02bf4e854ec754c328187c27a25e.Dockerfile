FROM ubuntu:14.04

LABEL maintainer "Alpeware <info@alpeware.com>"

EXPOSE 9222

RUN apt-get update -qqy \
  && apt-get -qqy install libnss3 libnss3-tools libfontconfig1 wget ca-certificates apt-transport-https inotify-tools \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ENV CHROME_VERSION=81.0.4044.129

RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install google-chrome-stable=${CHROME_VERSION}-1 \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN google-chrome-stable --version

ADD start.sh import_cert.sh /usr/bin/

RUN mkdir /data
VOLUME /data
ENV HOME=/data DEBUG_ADDRESS=0.0.0.0 DEBUG_PORT=9222

CMD ["/usr/bin/start.sh"]
