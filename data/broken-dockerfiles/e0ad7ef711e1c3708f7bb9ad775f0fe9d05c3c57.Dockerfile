FROM debian:jessie
MAINTAINER WangYan <i@wangyan.org>

# Build dependencies
RUN apt-get update && \
    apt-get install -y make gcc curl xz-utils net-tools supervisor iptables gnutls-bin libgnutls28-dev libev-dev \
    libwrap0-dev libpam0g-dev liblz4-dev libseccomp-dev libreadline-dev libnl-route-3-dev libkrb5-dev liboath-dev \
    libprotobuf-c0-dev libtalloc-dev libhttp-parser-dev libpcl1-dev libopts25-dev autogen protobuf-c-compiler gperf liblockfile-bin nuttcp && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN export LZ4_VERSION=`curl https://github.com/Cyan4973/lz4/releases/latest | sed -n 's/^.*tag\/\(.*\)".*/\1/p'` && \
    curl -SL "https://github.com/Cyan4973/lz4/archive/$LZ4_VERSION.tar.gz" -o lz4.tar.gz && \
    tar -xf lz4.tar.gz && cd ./lz4-* && \
    make -j$(nproc) && make install && \
    cd ../ && rm -rf ./lz4*

RUN export ocserv_version=$(curl -s  http://www.infradead.org/ocserv/download.html | grep -o '[0-9]*\.[0-9]*\.[0-9]*')  && \
    curl -O ftp://ftp.infradead.org/pub/ocserv/ocserv-$ocserv_version.tar.xz && \
    tar xvf ocserv-$ocserv_version.tar.xz && \
    cd ocserv-$ocserv_version && \
    ./configure && make -j$(nproc) && make install && \
    mkdir -p /etc/ocserv/certs && \
    cp doc/sample.config /etc/ocserv/ocserv.conf && \
    cd ../ && rm -rf ocserv*

# Ocserv config
RUN set -x \
    && sed -i 's/\.\/sample\.passwd/\/etc\/ocserv\/ocpasswd/' /etc/ocserv/ocserv.conf \
    && sed -i 's/\.\.\/tests/\/etc\/ocserv\/certs/' /etc/ocserv/ocserv.conf \
    && sed -i 's/max-clients = 16/max-clients = 32/' /etc/ocserv/ocserv.conf \
    && sed -i 's/ca\.pem/ca-cert\.pem/' /etc/ocserv/ocserv.conf \
    && sed -i 's/max-same-clients = 2/max-same-clients = 4/' /etc/ocserv/ocserv.conf \
    && sed -i 's/#enable-auth = \"certificate\"/enable-auth = \"certificate\"/' /etc/ocserv/ocserv.conf \
    && sed -i 's/#compression/compression/' /etc/ocserv/ocserv.conf \
    && sed -i 's/#no-compress-limit/no-compress-limit/' /etc/ocserv/ocserv.conf \
    && sed -i '/^ipv4-network = /{s/192.168.1.0/192.168.99.0/}' /etc/ocserv/ocserv.conf \
    && sed -i '/cert-user-oid = /{s/0.9.2342.19200300.100.1.1/2.5.4.3/}' /etc/ocserv/ocserv.conf \
    && sed -i 's/192.168.1.2/8.8.8.8/' /etc/ocserv/ocserv.conf \
    && sed -i 's/^route/#route/' /etc/ocserv/ocserv.conf \
    && sed -i 's/^no-route/#no-route/' /etc/ocserv/ocserv.conf

EXPOSE 443
VOLUME /etc/ocserv/

COPY cert.sh /cert.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /cert.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-n"]
