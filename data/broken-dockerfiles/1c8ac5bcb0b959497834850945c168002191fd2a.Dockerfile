FROM sillelien/base-alpine:0.9.2

RUN echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && apk upgrade && \
    apk-install curl fcron@testing bash

COPY *.sh /
RUN chmod 755 /run.sh
COPY cron.sh /etc/services.d/cron/run
RUN chmod 755 /etc/services.d/cron/run
CMD /run.sh

