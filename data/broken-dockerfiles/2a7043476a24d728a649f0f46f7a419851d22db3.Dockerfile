FROM resin/%%RESIN_MACHINE_NAME%%-node:slim

# Install wget and curl
RUN apt-get clean && apt-get update && apt-get install -y \
  wget \
  curl

# Add Kodi-16 apt source
RUN echo "deb http://pipplware.pplware.pt/pipplware/dists/jessie/main/binary /" \
>> /etc/apt/sources.list.d/pipplware_jessie.list && \
wget -O - http://pipplware.pplware.pt/pipplware/key.asc | sudo apt-key add -

# WTF is going on with httpredir from debian? removing it the dirty way
RUN sed -i "s@httpredir.debian.org@`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`@" /etc/apt/sources.list

# Install apt deps
RUN apt-get clean && apt-get update && apt-get upgrade -y && apt-get install -y \
  apt-utils \
  build-essential \
  libasound2-dev \
  libffi-dev \
  libssl-dev \
  python-dev \
  python-pip \
  git \
  alsa-base \
  alsa-utils \
  kodi && rm -rf /var/lib/apt/lists/*

# Configure for Kodi
COPY ./Dockerbin/99-input.rules /etc/udev/rules.d/99-input.rules
COPY ./Dockerbin/10-permissions.rules /etc/udev/rules.d/10-permissions.rules
RUN addgroup --system input && \
usermod -a -G audio root && \
usermod -a -G video root && \
usermod -a -G input root && \
usermod -a -G dialout root && \
usermod -a -G plugdev root && \
usermod -a -G tty root

# Set npm
RUN npm config set unsafe-perm true

# Uncomment if you want to Configure for pHAT DAC
# COPY ./Dockerbin/asound.conf /etc/asound.conf

# Save source folder
RUN printf "%s\n" "${PWD##}" > SOURCEFOLDER

# Move to app dir
WORKDIR /usr/src/app

# Move package.json to filesystem
COPY "$SOURCEFOLDER/app/package.json" ./

# NPM i app
RUN JOBS=MAX npm i --production

# Move app to filesystem
COPY "$SOURCEFOLDER/app" ./

# Move to /
WORKDIR /

## uncomment if you want systemd
ENV INITSYSTEM on

# Start app
CMD ["bash", "/usr/src/app/start.sh"]
