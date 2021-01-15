# Base image
#
# VERSION   0.1
FROM        paultag/acid:latest
MAINTAINER  Paul R. Tagliamonte <paultag@debian.org>

RUN mkdir -p /opt/hylang/snitch/
RUN apt-get update && apt-get install -y \
    git \
    python3-lxml \
    uwsgi \
    node-less \
    inkscape \
    pngcrush \
    uwsgi \
    uwsgi-plugin-python3 \
    python3-all-dev

ADD . /opt/hylang/snitch/

RUN cd /opt/hylang/snitch; python3.4 /usr/bin/pip3 install -e git+https://github.com/jmoiron/humanize#egg=humanize
RUN cd /opt/hylang/snitch; python3.4 /usr/bin/pip3 install -r requirements.txt
RUN cd /opt/hylang/snitch/web; python3.4 /usr/bin/pip3 install -r requirements.txt
RUN cd /opt/hylang/snitch; python3.4 /usr/bin/pip3 install -e .

RUN make -C /opt/hylang/snitch/web static
RUN adduser --system snitch

ADD web/uwsgi.ini /etc/uwsgi/apps-enabled/
CMD ["hy"]
