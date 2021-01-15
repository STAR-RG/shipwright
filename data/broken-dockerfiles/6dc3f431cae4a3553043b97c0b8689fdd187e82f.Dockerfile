FROM ubuntu:14.04
MAINTAINER keithyokoma <keith.yokoma@gmail.com>

# Basic environment setup
RUN apt-get update -y && apt-get upgrade -y && apt-get install git-core build-essential zip curl python-pip python-software-properties apt-file lib32z1 -y
RUN apt-file update -y
RUN apt-get install software-properties-common -y
RUN apt-add-repository ppa:brightbox/ruby-ng -y && dpkg --add-architecture i386 && apt-get update -y && apt-get install libncurses5:i386 libstdc++6:i386 zlib1g:i386 ruby2.3 ruby2.3-dev -y

# Java setup
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update -y && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
RUN \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update -y && \
    apt-get install -y oracle-java7-installer && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk7-installer

# Android SDK installation
RUN cd /usr/local/ && curl -L -O http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && tar xf android-sdk_r24.4.1-linux.tgz && \
    echo y | /usr/local/android-sdk-linux/tools/android update sdk --no-ui --force --all --filter "tools" && \
    echo y | /usr/local/android-sdk-linux/tools/android update sdk --no-ui --force --all --filter "platform-tools,build-tools-25.0.1,android-25" && \
    echo y | /usr/local/android-sdk-linux/tools/android update sdk --no-ui --force --all --filter "extra-google-google_play_services,extra-google-m2repository,extra-android-m2repository,addon-google_apis-google-23" && \
    rm -rf /usr/local/android-sdk_r24.4.1-linux.tgz

# Install Android NDK
RUN cd /usr/local && curl -L -O https://dl.google.com/android/repository/android-ndk-r13-linux-x86_64.zip && unzip android-ndk-r13-linux-x86_64.zip && rm -rf android-ndk-r13-linux-x86_64.zip

# Environment variables
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV JAVA8_HOME /usr/lib/jvm/java-8-oracle
ENV JAVA7_HOME /usr/lib/jvm/java-7-oracle
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV ANDROID_NDK_HOME /usr/local/android-ndk-r13
ENV GRADLE_HOME /usr/local/gradle-2.10
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools
ENV PATH $PATH:$ANDROID_NDK_HOME
ENV PATH $PATH:$GRADLE_HOME/bin
