# based on https://hub.docker.com/r/base/devel/
FROM base/arch
MAINTAINER jantman
# for some issues 2015-09
RUN pacman -Sy --noconfirm archlinux-keyring
RUN pacman -Sy --noconfirm ncurses readline bash
RUN pacman -Syu --noconfirm
RUN pacman-db-upgrade
RUN pacman -S --needed --noconfirm base-devel
RUN pacman -S --noconfirm git rsync strace
RUN rm /var/cache/pacman/pkg/*
# this is **my** local user...
USER 1000

