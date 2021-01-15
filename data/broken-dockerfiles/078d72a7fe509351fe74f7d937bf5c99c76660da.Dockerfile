FROM python:3.5
MAINTAINER Arne Schubert<atd.schubert@gmail.com>

ENV MAPPROXY_VERSION 1.11.0
ENV MAPPROXY_PROCESSES 4
ENV MAPPROXY_THREADS 2

RUN set -x \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    python-imaging \
    python-yaml \
    libproj12 \
    libgeos-dev \
    python-lxml \
    libgdal-dev \
    build-essential \
    python-dev \
    libjpeg-dev \
    zlib1g-dev \
    libfreetype6-dev \
    python-virtualenv \
  && rm -rf /var/lib/apt/lists/* \
  && useradd -ms /bin/bash mapproxy \
  && mkdir -p /mapproxy \
  && chown mapproxy /mapproxy \
  && pip install --upgrade pip \
  && pip install Shapely Pillow requests geojson uwsgi MapProxy==$MAPPROXY_VERSION  \
  && mkdir -p /docker-entrypoint-initmapproxy.d

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["mapproxy"]

USER mapproxy
VOLUME ["/mapproxy"]
EXPOSE 8080
# Stats
EXPOSE 9191
