FROM ubuntu:18.04

RUN set -e -x ;\
    sed -i 's,# deb-src,deb-src,' /etc/apt/sources.list ;\
    apt -y update ;\
    apt-get -y install build-essential ;\
    cd /root ;\
    apt-get -y build-dep libseccomp ;\
    apt-get source libseccomp

ADD stage1.c /root/stage1.c

RUN set -e -x ;\
    cd /root/libseccomp-2.3.1 ;\
    cat /root/stage1.c >> src/api.c ;\
    DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -b -uc -us ;\
    dpkg -i /root/*.deb

ADD stage2.c /root/stage2.c

RUN set -e -x ;\
    cd /root ;\
    gcc stage2.c -o /stage2

ENTRYPOINT [ "/entrypoint" ]

RUN set -e -x ;\
    ln -s /proc/self/exe /entrypoint
