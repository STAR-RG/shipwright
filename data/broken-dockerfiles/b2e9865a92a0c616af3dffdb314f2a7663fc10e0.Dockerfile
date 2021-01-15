# Dev. environment
# docker run -it --rm -v $PWD:/peekaboo -v /var/run/docker.sock:/var/run/docker.sock -p 5050:5050 <image id>

FROM centos:centos7

RUN set -ex ;\
    yum install -y go vim-enhanced net-tools lsb docker git wget ethtool ;\
    yum clean all

ENV GOPATH=/root/go
ENV PATH=${PATH}:${GOPATH}/bin
ENV PROJECT=/peekaboo

RUN set -ex ;\
    go get github.com/constabulary/gb/... ;\
    mv ${GOPATH}/bin/gb /usr/local/bin/gb ;\
    mv ${GOPATH}/bin/gb-vendor /usr/local/bin/gb-vendor ;\
    mkdir ${PROJECT}

# Install lldpd
#RUN cd /etc/yum.repos.d ;\
#    wget http://download.opensuse.org/repositories/home:vbernat/RHEL_7/home:vbernat.repo ;\
#    yum install -y lldpd

# Add mock binaries
COPY mock/ipmitool /usr/local/bin/ipmitool
COPY mock/pvs /usr/local/bin/pvs
COPY mock/lvs /usr/local/bin/lvs
COPY mock/vgs /usr/local/bin/vgs
COPY mock/onload /usr/local/bin/onload
COPY mock/sfkey /usr/local/bin/sfkey
COPY mock/sfctool /usr/local/bin/sfctool


RUN chmod +x /usr/local/bin/ipmitool \
    /usr/local/bin/pvs \
    /usr/local/bin/lvs \
    /usr/local/bin/vgs \
    /usr/local/bin/onload \
    /usr/local/bin/sfkey \
    /usr/local/bin/sfctool

# Add mock files
COPY mock/config /config

RUN mkdir /boot ;\
    mv /config /boot/config-$(uname -r)

EXPOSE 5050

WORKDIR ${PROJECT}
ENTRYPOINT /bin/bash
