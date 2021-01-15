FROM prom/prometheus
ENV  CONSUL_VERSION 0.8.0
ENV  ARCH linux_amd64

RUN echo prometheus:x:1000:100:guest:/dev/null:/sbin/nologin >> /etc/passwd && \
    mv /etc/prometheus/consoles/index.html.example /etc/prometheus/consoles/index.html && \
    apk add --update openssl && apk add --update -X http://dl-4.alpinelinux.org/alpine/edge/testing runit && \
    wget -O - https://github.com/hashicorp/consul-template/releases/download/v${CONSUL_VERSION}/consul-template_${CONSUL_VERSION}_${ARCH}.tar.gz | \
    tar -C /tmp -xzf - && mv /tmp/consul-template*/consul-template /usr/bin && \
    rm -rf /tmp/consul-template* && apk del --purge openssl

ENTRYPOINT  [ "/etc/prometheus.run" ]
ADD         . /etc
ONBUILD ADD . /etc
