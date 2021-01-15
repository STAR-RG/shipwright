FROM ubuntu:18.04
LABEL maintainer="Yorick van Zweeden"

# Variables taken from variables.env
ARG AVD_NAME
ARG ANDROID_HOME
ARG VERSION_COMPILE_VERSION
ARG VERSION_SDK_TOOLS

# Expect requires tzdata, which requires a timezone specified
RUN ln -fs /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime

RUN apt-get -qq update && \
      apt-get install -qqy --no-install-recommends \
      bridge-utils \
      bzip2 \
      curl \
      # expect: Passing commands to telnet
      expect \
      git-core \
      html2text \
      lib32gcc1 \
      lib32ncurses5 \
      lib32stdc++6 \
      lib32z1 \
      libc6-i386 \
      libqt5svg5 \
      libqt5widgets5 \
      # libvirt-bin: Virtualisation for emulator
      libvirt-bin \
      openjdk-8-jdk \
      # qemu-kvm: Hardware acceleration for emulator
      qemu-kvm \
      # telnet: Communicating with emulator
      telnet \
      # ubuntu-vm-builder: Building VM for emulator
      ubuntu-vm-builder \
      unzip \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configurating Java
RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Downloading SDK-tools (AVDManager, SDKManager, etc)
RUN curl -s https://dl.google.com/android/repository/sdk-tools-linux-"${VERSION_SDK_TOOLS}".zip > /sdk.zip && \
    unzip /sdk.zip -d /sdk && \
    rm -v /sdk.zip

# Add Android licences instead of acceptance
RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "d56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license

# Download packages
ADD packages.txt /sdk
RUN mkdir -p /root/.android && \
  touch /root/.android/repositories.cfg && \
  ${ANDROID_HOME}/tools/bin/sdkmanager --update 
RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt && \
    ${ANDROID_HOME}/tools/bin/sdkmanager ${PACKAGES}

# Download system image for compiled version (separate statement for build cache)
RUN echo y | ${ANDROID_HOME}/tools/bin/sdkmanager "system-images;android-${VERSION_COMPILE_VERSION};google_apis;x86_64"

# Create AVD
RUN mkdir ~/.android/avd  && \
      echo no | ${ANDROID_HOME}/tools/bin/avdmanager create avd -n ${AVD_NAME} -k "system-images;android-${VERSION_COMPILE_VERSION};google_apis;x86_64"

# Copy scripts to container for running the emulator and creating a snapshot
COPY scripts/* /