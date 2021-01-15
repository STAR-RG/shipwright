FROM fedora:26
LABEL maintainer="bkabrda@redhat.com"

RUN mkdir -p /var/dgdir
WORKDIR /var/dgdir

RUN dnf install python3-pip && dnf clean all
COPY . /tmp/distgen
RUN cd /tmp/distgen && pip3 install .

ENTRYPOINT ["/usr/bin/dg"]
