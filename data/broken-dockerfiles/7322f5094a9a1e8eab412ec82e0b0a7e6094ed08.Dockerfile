FROM node:10-stretch

WORKDIR /app

RUN apt-get -y update 

# ------- WOFF2 ---------

RUN apt-get -y install && \
    git clone --recursive https://github.com/google/woff2.git /usr/share/woff2 && \
    cd /usr/share/woff2 && \
    make clean all && \
    ln -svf /usr/share/woff2/woff2_compress /usr/bin/woff2_compress

# ------- PROCESSORS ---------

RUN npm i -g svgo

RUN apt-get -y install imagemagick jpegoptim pngquant gifsicle webp

# ------- FONT FORGE ---------

RUN apt-get -y install autotools-dev libjpeg-dev libtiff5-dev libpng-dev libgif-dev libxt-dev libfreetype6-dev autoconf automake libtool libltdl7-dev libxml2-dev libuninameslist-dev libspiro-dev python-dev libpango1.0-dev libcairo2-dev chrpath unifont 

RUN git clone https://github.com/fontforge/libspiro.git /usr/share/libspiro && \
    cd /usr/share/libspiro && \
    autoreconf -i && \
    automake --foreign -Wall && \
    ./configure && \
    make && \
    make install

RUN git clone https://github.com/fontforge/libuninameslist.git /usr/share/libuninameslist && \
    cd /usr/share/libuninameslist && \
    autoreconf -i && \
    automake --foreign && \
    ./configure && \
    make && \
    make install

RUN git clone https://github.com/fontforge/fontforge.git /usr/share/fontforge && \
    cd /usr/share/fontforge && \
    ./bootstrap && \
    ./configure && \
    make && \
    make install && \
    ldconfig

# ------- FFMPEG ---------

RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz && \
    tar -xf ffmpeg-release-amd64-static.tar.xz && \
    cp ffmpeg*/ff* /usr/local/bin/ && \
    rm -rf ffmpeg*

# ------- CSS PROCESSORS ---------

RUN npm -g install less

RUN cd /usr/share && \
    curl -L -o sass.tar.gz https://github.com/sass/dart-sass/releases/download/1.14.3/dart-sass-1.14.3-linux-x64.tar.gz && \
    ls -la && \
    tar -xvf sass.tar.gz && \
    rm sass.tar.gz && \
    cd dart-sass && \
    ln -svf /usr/share/dart-sass/sass /usr/local/bin/sass

# ------- APP ---------

COPY package.json package-lock.json /app/
RUN npm i

COPY tommy.js cli.js config.json /app/
RUN npm link

COPY lib /app/lib

ENTRYPOINT ["/usr/local/bin/tommy"]
