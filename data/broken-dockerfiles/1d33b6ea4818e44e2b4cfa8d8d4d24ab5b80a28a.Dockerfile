FROM ubuntu:14.04.3

MAINTAINER Chris Daish <chrisdaish@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN useradd -m libreoffice; \
    apt-get update \
    && apt-get install -y --no-install-recommends wget \
                                                  libdbus-glib-1-2 \
                                                  libsm6 \
                                                  openjdk-7-jre \
    && rm -rf /var/lib/apt/lists/*

ENV LIBREOFFICEPACKAGE LibreOffice_5.3.4_Linux_x86-64_deb.tar.gz
ENV LIBREOFFICEDIR LibreOffice_5.3.4.2_Linux_x86-64_deb

RUN wget -q http://mirror.switch.ch/ftp/mirror/tdf/libreoffice/stable/5.3.4/deb/x86_64/$LIBREOFFICEPACKAGE -O /tmp/$LIBREOFFICEPACKAGE \
    && mkdir /tmp/LibreOffice \
    && tar -xzf /tmp/$LIBREOFFICEPACKAGE -C /tmp/LibreOffice \
    && dpkg -i /tmp/LibreOffice/$LIBREOFFICEDIR/DEBS/*.deb \
    && rm -f /tmp/$LIBREOFFICEPACKAGE \
    && rm -rf /tmp/LibreOffice

COPY start-libreoffice.sh /tmp/

ENTRYPOINT ["/tmp/start-libreoffice.sh"]
