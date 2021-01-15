###########################################################
# Dockerfile for custom Arch Linux base to be as small as possible
#
# Currently 119 MB
############################################################

FROM dock0/arch
MAINTAINER Jonathan Yantis <yantis@yantis.net>

ENV TERM xterm
WORKDIR /tmp

RUN pacman -Syyu --noconfirm && \

    ## Configure pacman

    # Fix for failed: IPC connect call failed
    dirmngr </dev/null > /dev/null 2>&1 && \

    # Allow for colored output in pacman.conf
    sed -i "s/#Color/Color/" /etc/pacman.conf && \

    # Add hercula repo for vim-tiny
    # Removed this even though it is nice because it blocks dockerhub
    # http://repo.herecura.eu/herecura-stable/x86_64/
    # echo "[herecura-stable]" >> /etc/pacman.conf && \
    # echo "Server = http://repo.herecura.be/herecura-stable/\$arch" >> /etc/pacman.conf && \

    # Archlinux CN repo (has yaourt and sometimes other interesting tools)
    echo "[archlinuxcn]" >> /etc/pacman.conf && \
    echo "SigLevel = Optional TrustAll" >> /etc/pacman.conf && \
    echo "Server = http://repo.archlinuxcn.org/\$arch" >> /etc/pacman.conf && \

    # BlackArch
    echo "[blackarch]" >> /etc/pacman.conf && \
    echo "Server = http://mirror.clibre.uqam.ca/blackarch/\$repo/os/\$arch" >> /etc/pacman.conf && \
    pacman-key -r 4345771566D76038C7FEB43863EC0ADBEA87E4E3 && \
    pacman-key --lsign-key 4345771566D76038C7FEB43863EC0ADBEA87E4E3 && \
    pacman-key -r 7533BAFE69A25079 && \
    pacman-key --lsign-key 7533BAFE69A25079 && \

    # BBQLinux
    echo "[bbqlinux]" >> /etc/pacman.conf && \
    echo "Server = http://packages.bbqlinux.org/\$repo/os/\$arch" >> /etc/pacman.conf && \
    pacman-key -r 04C0A941 && \
    pacman-key --lsign-key 04C0A941 && \

    # Add multilib repo
    sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/ s/#//' /etc/pacman.conf && \
    sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/ s/#//' /etc/pacman.conf && \
    sed -i 's/#\[multilib\]/\[multilib\]/g' /etc/pacman.conf && \

    # Remove PGP Checks from dock0 amylum repo
    # https://github.com/amylum/repo
    sed -i 's/SigLevel = Required/SigLevel = Optional TrustAll/g' /etc/pacman.conf && \

    # Update and force a refresh of all package lists even if they appear up to date.
    pacman -Syyu --noconfirm && \

    # Install all the repo keyrings and mirrorlists
    pacman --noconfirm -S archlinuxcn-keyring blackarch-keyring bbqlinux-keyring && \

    # Install yaourt, package-query and cower for easy AUR usage.
    # TODO make sure package query still exists later after yaourt uninstall
    pacman -S --noconfirm yaourt package-query cower && \

    # TODO switch to rankmirrors since its built in for pacman.
    # Setup pacman to use the fastest mirrors.
    pacman -S reflector --noconfirm && \
    reflector --verbose -l 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist && \
    pacman -Rs reflector --noconfirm && \

    # Create new account that isn't root. user: docker password: docker
    useradd --create-home docker && \
    echo -e "docker\ndocker" | passwd docker && \

    # Allow passwordedless sudo for now but we will remove it later.
    pacman --noconfirm -S sudo  && \
    echo "docker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \

    # Replace texinfo with a fake textinfo so we can remove Perl

    pacman --noconfirm -S wget file patch binutils gcc autoconf make fakeroot && \
    # runuser -l docker -c "yaourt --noconfirm -Rdd texinfo" && \
    # runuser -l docker -c "yaourt --noconfirm -S texinfo-fake" && \

    # Install localepurge
    runuser -l docker -c "yaourt --noconfirm -S localepurge" && \

    # Configure localepurge
    sed -i "s/NEEDSCONFIGFIRST/#NEEDSCONFIGFIRST/" /etc/locale.nopurge && \
    sed -i "s/#DONTBOTHERNEWLOCALE/DONTBOTHERNEWLOCALE/" /etc/locale.nopurge && \

    # Reinstall openssl without a Perl dependency (This really isn't needed. Seriously)
    # Patch makepkg so we can run as it as root.
    # sed -i 's/EUID == 0/EUID == -1/' /usr/bin/makepkg && \
    #     wget --content-disposition "https://git.archlinux.org/svntogit/packages.git/plain/trunk/ssl3-test-failure.patch?h=packages/openssl" && \
    #     wget --content-disposition "https://git.archlinux.org/svntogit/packages.git/plain/trunk/ca-dir.patch?h=packages/openssl" && \
    #     wget --content-disposition "https://git.archlinux.org/svntogit/packages.git/plain/trunk/no-rpath.patch?h=packages/openssl" && \
    #     wget --content-disposition "https://git.archlinux.org/svntogit/packages.git/plain/trunk/PKGBUILD?h=packages/openssl" && \
    #     sed -i "s/depends=('perl')/depends=('pacman')/" PKGBUILD && \
    #     sed -i "s/make test//" PKGBUILD && \
    #     makepkg --noconfirm -si --skippgpcheck && \

    # Unpatch makepkg
    # sed -i 's/EUID == -1/EUID == 0/' /usr/bin/makepkg && \

    # Remove stuff we used for compliling packages since huge (219 mB)
    pacman --noconfirm -Runs  \
    binutils  \
    gcc \
    make \
    autoconf \
    # perl \
    yaourt \
    diffutils \

    # Remove other stuff
    gzip \
    # wget \
    # file \
    # patch \
    sudo \
    gettext \
    less \
    sysfsutils \
    which \
    git \

    # (7.1MB) Iproute2 and iptables
    iproute2 \

    # (1.76MB) Utilities for monitoring your system and its processes
    procps-ng \

    # .73 MB
    iputils && \

    # Remove stuff that still needs subitems
    pacman --noconfirm -R \
    util-linux \
    fakeroot \
    shadow && \


    # Remove ducktape & shim & leftover mirrorstatus.
     # rm -r /.ducktape /.shim && \
     rm /tmp/.root.mirrorstatus.json && \

##########################################################################
# CLEAN UP SECTION - THIS GOES AT THE END                                #
##########################################################################
    localepurge && \

    # Remove info, man and docs
    rm -r /usr/share/info/* && \
    rm -r /usr/share/man/* && \
    rm -r /usr/share/doc/* && \

    # was a bit worried about these at first but I haven't seen an issue yet on them.
    rm -r /usr/share/zoneinfo/* && \
    rm -r /usr/share/i18n/* && \

    # Delete any backup files like /etc/pacman.d/gnupg/pubring.gpg~
    find /. -name "*~" -type f -delete && \

    # Keep only xterm related profiles in terminfo.
    find /usr/share/terminfo/. ! -name "*xterm*" ! -name "*screen*" ! -name "*screen*" -type f -delete && \

    # Remove anything left in temp.
    rm -r /tmp/* && \

    pacman -S --noconfirm awk && \
    bash -c "echo 'y' | pacman -Scc >/dev/null 2>&1" && \
    paccache -rk0 >/dev/null 2>&1 &&  \
    pacman-optimize && \
    pacman -Runs --noconfirm gawk tar && \
    rm -r /var/lib/pacman/sync/*

#########################################################################

WORKDIR /
CMD /usr/bin/bash
