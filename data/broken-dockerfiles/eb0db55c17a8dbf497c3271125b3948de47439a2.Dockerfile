FROM quay.io/coreos/hyperkube:v1.10.3_coreos.0

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -yy curl && \
    curl https://raw.githubusercontent.com/ceph/ceph/master/keys/release.asc | apt-key add - && \
    echo deb http://download.ceph.com/debian-jewel/ jessie main | tee /etc/apt/sources.list.d/ceph.list && \
    DEBIAN_FRONTEND=noninteractive apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -yy ceph-common && \
    DEBIAN_FRONTEND=noninteractive apt-get autoremove -y && \
    DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
