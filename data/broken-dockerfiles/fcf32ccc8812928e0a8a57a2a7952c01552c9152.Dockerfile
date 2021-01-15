FROM centos:7
MAINTAINER pclm-team@altair.com

# Prevent troubles with random IPV6 returned for yum repos
RUN echo "ip_resolve=4" >> /etc/yum.conf

# Package centos-release solves the HTTP 404 error of YUM due to uninterpolated URL
# eg. "http://mirror.centos.org/%24contentdir/7/virt/x86_64/kvm-common/repodata/repomd.xml"
RUN yum makecache && yum install -y epel-release deltarpm centos-release && yum update -y && \
    yum install -y gcc python-pip python-devel git docker-client && \
    yum clean all

ENV TZ=UTC

RUN curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

# Update setuptools
RUN pip install --upgrade setuptools

ENV PKR_PATH=/pkr/
COPY pkr $PKR_PATH/pkr
COPY setup.py requirements.txt README.md $PKR_PATH

RUN cd $PKR_PATH && pip install .

COPY env $PKR_PATH/env
COPY templates $PKR_PATH/templates

VOLUME $PKR_PATH/kard

CMD pkr
