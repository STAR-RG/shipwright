# docker create -it --name arch nning2/compile-linux-grsec /bin/bash
# docker start -ai arch

FROM base/archlinux:latest
MAINTAINER henning mueller <mail@nning.io>

RUN pacman -Sy --noconfirm base-devel vim git ruby bc openssh \
	&& sed -i s:md5:sha256:g /etc/makepkg.conf \
	&& useradd -m compile \
	&& rm -rf /var/cache/pacman/pkg/* \
	&& su - compile -c "git clone git://github.com/nning/linux-grsec.git" \
	&& su - compile -c "gem install nokogiri" \
	&& su - compile -c "gpg --keyserver pgp.mit.edu --recv-keys 79BE3E4300411886 38DBBDC86092693E 44D1C0F82525FE49"
