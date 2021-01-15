FROM ubuntu:14.04
#
# Docker file used to build packages for .rpm and .deb
# based distributions.
# To propertly build package run in project directory:
#
# $ make build && make pack
# or
# $ make all
#
# For details refer to README.md file.
#
# Requires installed docker.
#
ENV GOPATH /golang
ENV DESCRIPTION 'AppCop - Marathon applications law enforcement'
ENV MAINTAINER "Allegro"

RUN apt-get update && apt-get install -y software-properties-common
RUN apt-add-repository -y ppa:brightbox/ruby-ng
RUN apt-get update && apt-get install -y \
	python-software-properties \
	build-essential ruby2.1 \
	ruby-switch \
	ruby2.1-dev \
	rpm

RUN gem install fpm

ADD . /work

ENTRYPOINT cd /work && fpm -s dir -t deb \
	--deb-upstart debian/appcop.upstart \
	--deb-systemd debian/appcop.service \
	-n appcop \
	-v `cat ./VERSION` \
	-m "$MAINTAINER" \
	--description "$DESCRIPTION" \
	build/appcop=/usr/bin/ \
	&& mv *deb dist/ && \
	fpm -s dir -t rpm  \
	-n appcop \
	-v `cat ./VERSION` \
	-m "$MAINTAINER" \
	--description "$DESCRIPTION" \
	build/appcop=/usr/bin/ \
	debian/appcop.service=/etc/systemd/system/appcop.service \
	debian/appcop.service=/etc/init/appcop.conf \
	&& mv *rpm dist/

