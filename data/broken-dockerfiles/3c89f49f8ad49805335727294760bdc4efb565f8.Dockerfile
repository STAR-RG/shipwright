FROM heichblatt/archlinux-yaourt

ARG REPO=https://github.com/badele/docker-dotfiles.git 

# Fix package-query
USER root
RUN pacman --noconfirm -R yaourt package-query
RUN pacman --noconfirm -Syu

# yaourt reinstallation
USER user
RUN cd /tmp && git clone https://aur.archlinux.org/package-query.git
RUN cd /tmp/package-query && makepkg --noconfirm -si
RUN cd /tmp && git clone https://aur.archlinux.org/yaourt.git
RUN cd /tmp/yaourt && makepkg --noconfirm -si

# Update AUR packages
RUN yaourt --noconfirm -Sua

# System configuration
USER root
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen

# Install some graphical packages
#USER user
#RUN yaourt --noconfirm -S xorg-server xorg-apps xorg-xinit xterm pulseaudio pulseaudio-ctl
#RUN yaourt --noconfirm -S openssh zsh

# Python
#RUN yaourt --noconfirm -S python-pip python-virtualenvwrapper 
#RUN yaourt --noconfirm -S npm

USER root 

# Clone user dotfiles
RUN cd /etc/skel && git clone $REPO 

# Install commons dotfiles packages
# If the dotfiles_install_commons file is modified in your dotfile,
# you must build docker image with "docker build --no-cache -t badele/docker-dotfiles ."
USER user
RUN /etc/skel/docker-dotfiles/commons/user/.bin/dotfiles_install_bootstrap
RUN /etc/skel/docker-dotfiles/commons/user/.bin/dotfiles_install_commons
RUN /etc/skel/docker-dotfiles/commons/user/.bin/dotfiles_sync_for_computer

USER root

RUN echo -e '#! /bin/zsh\n \
[ -e "$HOME/docker-dotfiles" ] || cp -R /etc/skel/. $HOME/ \n\
cd $HOME/docker-dotfiles && git pull \n\
\n\
# Sudoers configuration\n\
echo x11docker | sudo --stdin su -c "echo \"$USER ALL=(ALL) NOPASSWD:ALL\"  > /etc/sudoers"\n\ 
echo x11docker | sudo --stdin su -c "echo \"root ALL=(ALL) ALL\" >> /etc/sudoers"\n\ 
\n\
# Get user configuration (depend computer)
cd $HOME/docker-dotfiles &&  /$HOME/docker-dotfiles/commons/user/.bin/dotfiles_get_for_computer \n\
\n\

export PATH=$HOME/.bin:$PATH \n\
cd\n\
exec $* \n\
' > /usr/local/bin/start 
RUN chmod +x /usr/local/bin/start

ENTRYPOINT ["/usr/local/bin/start"]

CMD ["dotfiles_launch_system"]
