FROM debian:jessie
MAINTAINER Matt Bentley <mbentley@mbentley.net>

RUN (apt-get update &&\
  DEBIAN_FRONTEND=noninteractive apt-get install -y gcc make autoconf automake gettext git \
    python-cherrypy3 python-cheetah python-libvirt \
    libvirt-bin python-imaging python-configobj \
    python-pam python-m2crypto python-jsonschema \
    qemu-kvm libtool python-psutil python-ethtool \
    sosreport python-ipaddr python-ldap \
    python-lxml nfs-common open-iscsi lvm2 xsltproc \
    python-parted nginx python-guestfs libguestfs-tools \
    websockify novnc spice-html5)

RUN (git clone https://github.com/kimchi-project/kimchi.git &&\
  cd kimchi &&\
  ./autogen.sh --system &&\
  make &&\
  make install &&\
  cd / &&\
  rm -rf /var/lib/kimchi/isos /kimchi)

RUN (sed -i "s/#create_iso_pool = true/create_iso_pool = false/g" /etc/kimchi/kimchi.conf &&\
  sed -i "s/#display_proxy_port = 64667/display_proxy_port = 64668/g" /etc/kimchi/kimchi.conf)

ENTRYPOINT ["kimchid"]
CMD ["--host=0.0.0.0"]
