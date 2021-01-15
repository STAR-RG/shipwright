FROM ubuntu:14.04

RUN set -e -x ; \
      dpkg --add-architecture i386 ; \
      DEBIAN_FRONTEND=noninteractive apt-get update ; \
      apt-get -y install x11-apps xauth wget xvfb ; \
      DEBIAN_FRONTEND=noninteractive apt-get -y install libgtk2.0-0:i386 libstdc++6:i386 libnss3-1d:i386 lib32nss-mdns libxml2:i386 libxslt1.1:i386 libxslt1.1 libcanberra-gtk-module:i386 gtk2-engines-murrine:i386 libqt4-qt3support:i386 libgnome-keyring0:i386

RUN ln -s /usr/lib/i386-linux-gnu/libgnome-keyring.so.0 /usr/lib/libgnome-keyring.so.0
RUN ln -s /usr/lib/i386-linux-gnu/libgnome-keyring.so.0.2.0 /usr/lib/libgnome-keyring.so.0.2.0

# właściwe locale jest właściwe
# http://jaredmarkell.com/docker-and-locales/
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y language-pack-pl-base
RUN locale-gen pl_PL.UTF-8
ENV LANG pl_PL.UTF-8
ENV LANGUAGE pl_PL:pl
ENV LC_ALL pl_PL.UTF-8

#http://docs.docker.com/engine/articles/dockerfile_best-practices/#add-or-copy
RUN wget -O /opt/air.bin --progress=bar:force http://airdownload.adobe.com/air/lin/download/latest/AdobeAIRInstaller.bin \
      && chmod +x /opt/air.bin \
      && xvfb-run /opt/air.bin -silent -eulaAccepted \
      && rm /opt/air.bin

# via http://ask.xmodulo.com/install-adobe-reader-ubuntu-13-10.html
RUN wget -O /opt/acroread.deb --progress=bar:force http://ardownload.adobe.com/pub/adobe/reader/unix/9.x/9.5.5/enu/AdbeRdr9.5.5-1_i386linux_enu.deb \
      && DEBIAN_FRONTEND=noninteractive dpkg -i --force-architecture /opt/acroread.deb \
      && rm /opt/acroread.deb

#drukowanie
#http://superuser.com/questions/101675/printing-via-adobe-reader-under-linux-and-cups
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install cups-client cups-bsd
ADD cups_client.conf /etc/cups/client.conf
# właściwe ustawienie adresu jest przy odpalaniu kontenera - w skrypcie wrapper.sh
# UWAGA - pamiętaj o zmienie konfiguracji CUPS hosta zgodnie z opisem

# ADD, bo inaczej nie ma jak zaktualizować edeklaracji aby pobrać nowe formularze
ADD http://www.finanse.mf.gov.pl/documents/766655/1196444/e-DeklaracjeDesktop.air /opt/edeklaracje.air
RUN xvfb-run '/opt/Adobe AIR/Versions/1.0/Adobe AIR Application Installer' -silent -eulaAccepted /opt/edeklaracje.air

# reszta ustawień
ADD run.sh /opt/wrapper.sh
RUN chmod a+x /opt/wrapper.sh
WORKDIR /opt

RUN echo -ne "\n\nUruchom za pomocą ./edeklaracje.sh\n\n"

ENTRYPOINT ["/opt/wrapper.sh"]
