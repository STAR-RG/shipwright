FROM resin/rpi-node:0.10-wheezy

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    chromium-browser \
    fbset \
    htop \
    libnss3 \
    libraspberrypi-bin \
    matchbox \
    psmisc \
    sqlite3 \
    ttf-mscorefonts-installer \
    x11-xserver-utils \
    xinit \
    xwit

RUN mkdir -p /usr/src/app \
  && ln -s /usr/src/app /app

WORKDIR /usr/src/app

COPY . /usr/src/app

RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

CMD bash -C "/app/spawn_screen";"bash"
