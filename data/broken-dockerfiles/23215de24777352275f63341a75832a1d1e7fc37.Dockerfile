FROM alpine:latest

LABEL elasticsearch-curator=5.4.0

RUN apk --update add python py-setuptools py-pip && \
    pip install elasticsearch-curator==5.4.0 && \
    apk del py-pip && \
    rm -rf /var/cache/apk/*

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
