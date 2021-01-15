FROM ruby
WORKDIR /

# Prepare
RUN apt-get update
RUN apt-get install --fix-missing
RUN apt-get dist-upgrade -y
RUN apt-get update --fix-missing
# Install normal Packages needed
RUN apt-get install -f -y -u apt-utils unzip wget curl jruby nano screen htop openssl git


# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# Installing the packages needed to run Nightmare
RUN apt-get install -f -y \
  xvfb \
  x11-xkb-utils \
  xfonts-100dpi \
  xfonts-75dpi \
  xfonts-scalable \
  xfonts-cyrillic \
  x11-apps \
  clang \
  libdbus-1-dev \
  libgtk2.0-dev \
  libnotify-dev \
  libgnome-keyring-dev \
  libgconf2-dev \
  libasound2-dev \
  libcap-dev \
  libcups2-dev \
  libxtst-dev \
  libxss1 \
  libnss3-dev \
  gcc-multilib \
  g++-multilib

# Use aq domain.com to automated all options of aquatone.
RUN wget "https://gist.githubusercontent.com/random-robbie/beae1991e9ad139c6168c385d8a31f7d/raw/" -O /bin/aq
RUN chmod 777 /bin/aq

#install aquatone
RUN gem install aquatone
# set to bash so you can set keys before running aquatone.
ENTRYPOINT ["/bin/bash"]
