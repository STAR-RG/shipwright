FROM fedora:rawhide
MAINTAINER Vadim Rutkovsky <vrutkovs@redhat.com>

# Install dependencies
RUN dnf install -y libappstream-glib-devel autoconf autoconf-archive automake \
    intltool gcc glib2-devel make findutils tar xz

ADD . /opt/gnome-news/
WORKDIR /opt/gnome-news/

# Build
RUN ./autogen.sh && make

# Install required check tools
RUN dnf install -y python3-pep8 python3-pyflakes
