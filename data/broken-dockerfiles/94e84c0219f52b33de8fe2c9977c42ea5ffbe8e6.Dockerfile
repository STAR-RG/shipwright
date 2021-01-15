# Pull base image
FROM resin/rpi-raspbian:jessie
MAINTAINER Dieter Reuter <dieter@hypriot.com>

# Install OpenJDK 8 runtime without X11 support
RUN echo "deb http://ftp.debian.org/debian jessie-backports main" | sudo tee /etc/apt/sources.list.d/backports.list && \
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 8B48AD6246925553 && \
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 7638D0442B90D010 && \
    apt-get update && \
    apt-get -t jessie-backports install -y openjdk-8-jre-headless=8u111-b14-2~bpo8+1 --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Define working directory
WORKDIR /data

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-armhf

# Define default command
CMD ["bash"]
