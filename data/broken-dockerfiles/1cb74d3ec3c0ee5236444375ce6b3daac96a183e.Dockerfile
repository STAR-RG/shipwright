# apigateway-zmq-adaptor
#
# VERSION               0.1.0
#
# From https://hub.docker.com/_/alpine/
#
FROM alpine:latest

ENV ZMQ_VERSION 4.0.5
ENV CZMQ_VERSION 2.2.0
ENV ZMQ_ADAPTOR_VERSION 0.1.1

RUN apk update \
    && apk add \
           gcc tar libtool zlib make musl-dev openssl-dev g++ zlib-dev curl
RUN echo " ... adding ZMQ and CZMQ" \
         && curl -L https://s3.amazonaws.com/adobe-cloudops-apip-installers-ue1/3rd-party/zeromq-${ZMQ_VERSION}.tar.gz -o /tmp/zeromq.tar.gz \
         && cd /tmp/ \
         && tar -xf /tmp/zeromq.tar.gz \
         && cd /tmp/zeromq*/ \
         && ./configure --prefix=/usr \
                        --sysconfdir=/etc \
                        --mandir=/usr/share/man \
                        --infodir=/usr/share/info \
         && make && make install \
         && curl -L https://s3.amazonaws.com/adobe-cloudops-apip-installers-ue1/3rd-party/czmq-${CZMQ_VERSION}.tar.gz -o /tmp/czmq.tar.gz \
         && cd /tmp/ \
         && tar -xf /tmp/czmq.tar.gz \
         && cd /tmp/czmq*/ \
         && ./configure --prefix=/usr \
                        --sysconfdir=/etc \
                        --mandir=/usr/share/man \
                        --infodir=/usr/share/info \
         && make && make install \
         && rm -rf /tmp/zeromq* && rm -rf /tmp/czmq* \
         && rm -rf /var/cache/apk/* 

RUN apk update \
    && apk add libgcc libstdc++

# --- DEV ---
RUN apk update \
   && apk add \
          gcc tar libtool zlib make musl-dev openssl-dev g++ zlib-dev curl \
   && apk add check-dev
COPY src /tmp/api-gateway-zmq-adaptor-${ZMQ_ADAPTOR_VERSION}/src
COPY tests /tmp/api-gateway-zmq-adaptor-${ZMQ_ADAPTOR_VERSION}/tests
COPY Makefile /tmp/api-gateway-zmq-adaptor-${ZMQ_ADAPTOR_VERSION}/Makefile
RUN cd /tmp/api-gateway-zmq-adaptor-* \
       && make test \
       && mkdir -p /usr/local/sbin \
       && PREFIX=/usr/local/sbin make install \
       && rm -rf /tmp/api-gateway-zmq-adaptor-*
# ------------------

RUN apk del check-dev gcc tar libtool make musl-dev openssl-dev g++ zlib-dev curl \
    && rm -rf /var/cache/apk/*

COPY Docker-init.sh /etc/init-container.sh
ONBUILD COPY init.sh /etc/init-container.sh

# volume to expose IPC sockets
# http://api.zeromq.org/4-1:zmq-ipc
VOLUME /var/run/api-gateway-zmq-adaptor

ENTRYPOINT ["/etc/init-container.sh"]
