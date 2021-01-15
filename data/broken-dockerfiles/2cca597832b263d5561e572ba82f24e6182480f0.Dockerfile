## -*- docker-image-name: "munnerz/scaleway-kubernetes:amd64" -*-
FROM scaleway/debian:amd64-sid
MAINTAINER James Munnelly <james@munnelly.eu>

# Prepare rootfs for image-builder.
#   This script prevent aptitude to run services when installed
RUN /usr/local/sbin/builder-enter

# Install docker dependencies & upgrade system
RUN apt-get -q update \
	&& apt-get -y -qq upgrade \
	&& apt-get install -y -q \
		apparmor \
		arping \
		aufs-tools \
		btrfs-tools \
		bridge-utils \
		cgroupfs-mount \
		git \
		ifupdown \
		kmod \
		lxc \
		python-setuptools \
		vlan \
	&& apt-get clean

# Install docker
RUN curl -L https://get.docker.com/ | sh

# Add local files into the root (extra config etc)
COPY ./rootfs/ /

# Add early-docker group
RUN addgroup early-docker

RUN systemctl enable docker \
    && systemctl enable early-docker \
    && systemctl enable etcd \
    && systemctl enable flannel \
    && systemctl enable update-firewall \
    && systemctl enable kubelet

# Clean rootfs from image-builder.
#   Revert the builder-enter script
RUN /usr/local/sbin/builder-leave
