FROM nginx:stable

RUN echo "deb http://ftp.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie.backports.list

ENV SUPERVISOR_VERSION 3.3.0

RUN set -x \
    && apt-get update && apt-get install --no-install-recommends -yqq \
    cron \
    dnsmasq \
    wget \
    python-ndg-httpsclient \
    && apt-get install --no-install-recommends -yqq certbot -t jessie-backports \
    && wget https://github.com/Supervisor/supervisor/archive/${SUPERVISOR_VERSION}.tar.gz \
    && tar -xvf ${SUPERVISOR_VERSION}.tar.gz \
    && cd supervisor-${SUPERVISOR_VERSION} && python setup.py install \
    && apt-get clean autoclean && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY certbot-crontab /etc/cron.d/certbot
COPY supervisord.conf /etc/supervisord.conf
COPY certs.sh /
COPY bootstrap.sh /
COPY default.conf /etc/nginx/conf.d/default.conf

RUN mkdir /le-root

EXPOSE 80 443

VOLUME /etc/letsencrypt

ENTRYPOINT ["/bootstrap.sh"]
