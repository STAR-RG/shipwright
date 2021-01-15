FROM debian:buster
MAINTAINER "Giovanni Angoli <juzam76@gmail.com>"

RUN apt-get update && apt-get install -y libyaml-dev libssl-dev libtool-bin autoconf git make && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/getdnsapi/getdns.git

WORKDIR getdns

RUN git checkout master && git submodule update --init && libtoolize -ci && autoreconf -fi && mkdir build
WORKDIR build
RUN ../configure --without-libidn --without-libidn2 --enable-stub-only --with-stubby && make && make install && ldconfig

COPY stubby.yml /usr/local/etc/stubby/stubby.yml

EXPOSE 8053

CMD [ "/usr/local/bin/stubby" ]
