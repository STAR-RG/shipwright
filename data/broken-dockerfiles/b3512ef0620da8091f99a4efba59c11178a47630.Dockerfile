FROM ubuntu:17.10

MAINTAINER Jens Diemer "https://github.com/jedie/kivy-buildozer-docker"

# Update ubuntu:
RUN set -x \
    && apt-get update -qq \
    && apt-get -y full-upgrade \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install needed packages for buildozer
# base is https://github.com/kivy/buildozer/blob/master/buildozer/tools/packer/scripts/additional-packages.sh
# But we need some more tools here ;)
RUN set -x \
    && dpkg --add-architecture i386 \
    && apt-get update -qq \
    && apt-get -y install \
        lib32stdc++6 lib32z1 lib32ncurses5 \
        build-essential \
        python-pip unzip curl \
    && apt-get -y install git openjdk-8-jdk --no-install-recommends zlib1g-dev \
    && apt-get autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# The buildozer VM used Cython v0.25 and buildozer v0.32
RUN set -x \
    && python -m pip install --upgrade pip \
    && python -m pip install "cython<0.26" \
    && python -m pip install "buildozer!=0.33" python-for-android pyOpenssl

ADD kivy_hello_world /buildozer/kivy_hello_world

RUN set -x \
    && adduser buildozer --disabled-password --disabled-login \
    && chown -R buildozer:buildozer /buildozer/

USER buildozer

# download all needed andorid dependencies:
RUN set -x \
    && cd /buildozer/kivy_hello_world \
    && buildozer android release \
    && cd .. \
    && rm -rf kivy_hello_world

VOLUME /buildozer/

WORKDIR /buildozer/
