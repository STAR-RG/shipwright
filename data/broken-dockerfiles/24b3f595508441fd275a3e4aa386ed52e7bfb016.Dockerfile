FROM ubuntu:16.04

MAINTAINER Naftuli Kay <me@naftuli.wtf>

RUN apt-get update >/dev/null

ENV KERNEL_MAJOR=4.4.0

# get the latest kernel in the given major release
RUN apt-cache search linux-image-$KERNEL_MAJOR- | \
        grep -ioP "(?<=linux-image-)$KERNEL_MAJOR-\d+(?=-generic)" | sort -r | head -1 > /tmp/kernel-release

RUN apt-get build-dep -y linux-image-$(cat /tmp/kernel-release)-generic >/dev/null && \
    apt-get install -y fakeroot >/dev/null && \
    apt-get clean >/dev/null

RUN install --directory -m 0755 /data && \
    install --directory -m 0755 /patches

ADD scripts/kernel-build /usr/local/bin/kernel-build
RUN chmod 0755 /usr/local/bin/kernel-build

WORKDIR /data

VOLUME /data
VOLUME /patches

# we have to run as root so that we can apt-get update
ENTRYPOINT ["/usr/local/bin/kernel-build"]
