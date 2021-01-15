# Published as msparks/devbox on Docker Hub.
from ubuntu:16.04
maintainer Matt Sparks <ms@quadpoint.org>

run apt-get update && apt-get install -y \
  aptitude \
  build-essential \
  cmake \
  curl \
  diffstat \
  dnsutils \
  emacs24-nox \
  git \
  irssi \
  iptables \
  iputils-ping \
  netcat \
  net-tools \
  pkg-config \
  python \
  strace \
  sudo \
  tcpdump \
  telnet \
  tmux \
  traceroute \
  vim \
  wget \
  zsh \
  && apt-get clean

# Install go.
run curl https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz \
  | tar -C /usr/local -zx
env GOROOT /usr/local/go
env PATH /usr/local/go/bin:$PATH

# Unrestricted sudo.
run echo "ALL ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers

# Workaround: sudo in Ubuntu 14.10 images is missing the setuid bit.
# See https://github.com/tianon/docker-brew-ubuntu-core/issues/17. 14.04 is
# fixed but 14.10 isn't as of 2014-11-09.
run chown root:root /usr/bin/sudo
run chmod 4755 /usr/bin/sudo

# Timezone.
run cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

# UTF-8.
run dpkg-reconfigure locales && \
  locale-gen en_US.UTF-8 && \
  /usr/sbin/update-locale LANG=en_US.UTF-8

# Create user.
run useradd -m ms && \
  chown -R ms: /home/ms

# Shared data volume.
run mkdir /var/shared && \
  touch /var/shared/.placeholder && \
  chown -R ms:ms /var/shared
volume /var/shared

# Set up environment.
env HOME /home/ms
env PATH /home/ms/bin:$PATH
env PKG_CONFIG_PATH /home/ms/lib/pkgconfig
env LD_LIBRARY_PATH /home/ms/lib
env GOPATH /home/ms/go:$GOPATH
env LC_ALL en_US.UTF-8

# Install dotfiles.
add . /tmp/dotfiles
run chown -R ms:ms /tmp/dotfiles && \
  (cd /tmp/dotfiles && sudo -u ms ./install.sh) && \
  rm -rf /tmp/dotfiles

# User home directory.
user ms
run mkdir -p /home/ms/go /home/ms/bin /home/ms/lib /home/ms/include

workdir /home/ms
cmd ["/bin/zsh"]
