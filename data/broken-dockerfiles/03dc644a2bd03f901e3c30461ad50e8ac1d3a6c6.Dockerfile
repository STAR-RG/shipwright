FROM ibizaman/docker-archlinux

RUN pacman -Syu --noconfirm \
    gsettings-desktop-schemas \
    gtk2 \
    imagemagick \
    java-environment \
    libxrender \
    libxtst \
    socat \
    ttf-dejavu \
    unzip \
    xorg-server \
    xorg-server-xvfb

#TODO: remove skipchecksums whenever possible
RUN aur-install.sh ib-tws --skipchecksums
RUN aur-install.sh ib-controller --skipchecksums

RUN mkdir /var/run/xvfb/
RUN cp /etc/ibcontroller/edemo.ini /etc/ibcontroller/conf.ini
COPY start.sh /start.sh
RUN chmod a+x /start.sh

EXPOSE 4003

CMD ["/start.sh"]
