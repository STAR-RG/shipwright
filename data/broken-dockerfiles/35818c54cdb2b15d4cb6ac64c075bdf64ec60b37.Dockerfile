FROM ubuntu:18.04

RUN \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && perl -pi -e 's/archive.ubuntu.com/us.archive.ubuntu.com/' /etc/apt/sources.list \
    && apt-get update -y

RUN \
    apt-get install -y \
        build-essential \
        curl \
        git \
        lsb-base \
        lsb-release \
        sudo

RUN \
    cd / \
    && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

RUN \
    echo Etc/UTC > /etc/timezone

RUN \
    echo tzdata tzdata/Areas select Etc | debconf-set-selections

RUN \
    echo tzdata tzdata/Zones/Etc UTC | debconf-set-selections

RUN \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

ENV PATH=/depot_tools:$PATH

RUN \
    curl -s https://chromium.googlesource.com/chromium/src/+/master/build/install-build-deps.sh?format=TEXT | base64 -d \
    | perl -pe 's/if new_list.*/new_list=\$packages\nif false; then/' \
    | sed -e '/^  new_list/,+2d' \
    | perl -pe 's/apt-get install \$\{do_quietly-}/DEBIAN_FRONTEND=noninteractive apt-get install -y/' \
    | bash -e -s - \
        --no-syms \
        --no-arm \
        --no-chromeos-fonts \
        --no-nacl \
        --no-prompt \
        --unsupported

RUN \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
