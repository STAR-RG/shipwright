FROM fedora:24
MAINTAINER Tomas Tomecek <ttomecek@redhat.com>

RUN dnf install -y dnf-plugins-core && \
    dnf copr enable -y ttomecek/xmind && \
    dnf install -y xmind && \
    dnf clean all

ARG USER_ID=1000
RUN useradd -o -u ${USER_ID} -G video xmind
USER xmind
ENV HOME /home/xmind
CMD ["/usr/bin/xmind"]
