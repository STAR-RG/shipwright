FROM justbuchanan/docker-archlinux

RUN pacman -Syu --noconfirm

RUN pacman -S --noconfirm python

COPY ./ dotfiles
WORKDIR dotfiles

RUN python arch-install.py

ENTRYPOINT ["/usr/bin/zsh"]
