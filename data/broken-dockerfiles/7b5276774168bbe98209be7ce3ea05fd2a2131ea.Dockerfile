FROM resin/rpi-raspbian:wheezy

RUN set -ex; \
    apt-get update -qq; \
    apt-get install -y \
        python \
        python-pip \
        python-dev \
        git \
        apt-transport-https \
        ca-certificates \
        curl \
        lxc \
        iptables \
    ; \
    rm -rf /var/lib/apt/lists/*

ENV ALL_DOCKER_VERSIONS 1.6.0

RUN set -ex; \
    curl -L http://assets.hypriot.com/docker-hypriot_1.6.0-1_armhf.deb -o docker-hypriot_1.6.0-1_armhf.deb; \
    dpkg -x docker-hypriot_1.6.0-1_armhf.deb /tmp/docker || true; \
    mv /tmp/docker/usr/bin/docker /usr/local/bin/docker; \
    rm -rf /tmp/docker

RUN useradd -d /home/user -m -s /bin/bash user
WORKDIR /code/

ADD requirements.txt /code/
RUN pip install -r requirements.txt

ADD requirements-dev.txt /code/
RUN pip install -r requirements-dev.txt

RUN apt-get install -qy wget && \
    cd /tmp && \
    wget -q https://pypi.python.org/packages/source/P/PyInstaller/PyInstaller-2.1.tar.gz && \
    tar xzf PyInstaller-2.1.tar.gz && \
    cd PyInstaller-2.1/bootloader && \
    python ./waf configure --no-lsb build install && \
    ln -s /tmp/PyInstaller-2.1/PyInstaller/bootloader/Linux-32bit-arm /usr/local/lib/python2.7/dist-packages/PyInstaller/bootloader/Linux-32bit-arm

ADD . /code/
RUN python setup.py install

RUN chown -R user /code/

ENTRYPOINT ["/usr/local/bin/docker-compose"]
