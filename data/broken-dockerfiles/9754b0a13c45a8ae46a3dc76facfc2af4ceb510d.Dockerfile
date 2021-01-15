FROM fedora:23
MAINTAINER RyanJ <ryanj@redhat.com>

ENV DEMO_ANSIBLE_VERSION=demo-ansible-2.3.0 \
    DEMO_ANSIBLE_REPO=https://github.com/2015-Middleware-Keynote/demo-ansible \
    OPENSHIFT_ANSIBLE_VERSION=openshift-ansible-3.0.94-1-hotfix \
    OPENSHIFT_ANSIBLE_REPO=https://github.com/thoraxe/openshift-ansible.git \
#    ANSIBLE_RPM_URL=https://dl.fedoraproject.org/pub/epel/7/x86_64/a/ansible1.9-1.9.6-2.el7.noarch.rpm \
    ANSIBLE_RPM_URL=https://kojipkgs.fedoraproject.org/packages/ansible/1.9.4/1.el7/noarch/ansible-1.9.4-1.el7.noarch.rpm \
    ANSIBLE_RPM_NAME=ansible \
    HOME=/opt/src

VOLUME /opt/src/keys

RUN set -ex && \
  dnf update -y && \
  INSTALL_PKGS="git bzip2 python python-boto python-click pyOpenSSL" && \
  dnf install -y --setopt=tsflags=nodocs $INSTALL_PKGS $ANSIBLE_RPM_URL && \
  rpm -V $INSTALL_PKGS $ANSIBLE_RPM_NAME && \
  git clone $DEMO_ANSIBLE_REPO -b $DEMO_ANSIBLE_VERSION ${HOME}/demo-ansible && \
  git clone $OPENSHIFT_ANSIBLE_REPO -b $OPENSHIFT_ANSIBLE_VERSION ${HOME}/openshift-ansible && \
  dnf clean all -y && \
  rm -rf /usr/share/man /tmp/*

WORKDIR ${HOME}/demo-ansible

ENTRYPOINT [ "./run.py" ]
