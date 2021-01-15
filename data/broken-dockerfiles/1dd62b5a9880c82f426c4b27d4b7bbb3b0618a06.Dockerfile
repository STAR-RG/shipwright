FROM     debian:sid

# Base install
RUN dpkg --add-architecture i386 && \
    apt-get -q update && \
    apt-get -q upgrade -y && \
    apt-get -q install -y adduser libasound2:i386 libc6:i386 libfreetype6:i386 \
        libgcc1:i386 libsm6:i386 libxdamage1:i386 libxext6:i386 \
        libxfixes3:i386 libxrandr2:i386 libxrender1:i386 libxtst6:i386 sudo \
        wget zlib1g:i386 libjpeg8:i386 libexpat1:i386 fonts-liberation:i386 \
        libfontconfig1:i386 fontconfig-config:i386 ucf \
        libdbus-1-3:i386 libjpeg62:i386 libxinerama1:i386 \
        libpng12-0:i386 procps && \
    echo "hybris	ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/hybris

# Install teamviewer
RUN wget http://download.teamviewer.com/download/teamviewer_i386.deb -O /tmp/teamviewer_linux.deb && \
    dpkg -i /tmp/teamviewer_linux.deb

# Add user (same name, uid, gid !!)
RUN adduser --disabled-password --gecos hybris hybris

# Prepare env
USER hybris
ENV USER hybris
ENV DISPLAY :0.0

# Launch
CMD sudo service teamviewerd start && teamviewer
