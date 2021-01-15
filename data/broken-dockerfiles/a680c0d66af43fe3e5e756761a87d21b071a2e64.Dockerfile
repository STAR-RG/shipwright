FROM centos:7
MAINTAINER nekocode <nekocode.cn@gmail.com>

# Install Dependencies
RUN yum install -y wget unzip && \
    yum install -y glibc.i686 glibc-devel.i686 libstdc++.i686 zlib-devel.i686 ncurses-devel.i686 libX11-devel.i686 libXrender.i686 libXrandr.i686

# Download JDK 8
RUN wget -q --no-check-certificate -c \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    "http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz" \
    -O jdk8.tar.gz && \
    tar -xzf jdk8.tar.gz -C /opt && \
    rm jdk8.tar.gz

# Configure Java Environment
ENV JAVA8_HOME /opt/jdk1.8.0_112
ENV JAVA_HOME $JAVA8_HOME
ENV PATH $PATH:$JAVA_HOME/bin

# Download Android SDK tools
RUN wget -q "http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz" -O android-sdk.tgz && \
    tar -xzf android-sdk.tgz -C /opt && \
    rm android-sdk.tgz

# Configure Android SDK Environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH $PATH:$ANDROID_HOME/tools
ENV PATH $PATH:$ANDROID_HOME/platform-tools
ENV PATH $PATH:$ANDROID_HOME/build-tools/24.0.3

# Install Android SDK components
RUN echo y | android update sdk --no-ui --all --filter \
    "platform-tools,build-tools-23.0.3,build-tools-24.0.3,android-23,android-24" && \
    echo y | android update sdk --no-ui --all --filter \
    "extra-android-m2repository,extra-google-m2repository,extra-android-support"

# Setup Gradle
ENV GRADLE_VERSION 3.1
RUN wget -q "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -O gradle.zip && \
    unzip -q gradle.zip -d /opt && \
    ln -s "/opt/gradle-${GRADLE_VERSION}/bin/gradle" /usr/bin/gradle && \
    rm gradle.zip

# Configure Gradle Environment
ENV GRADLE_HOME /opt/gradle-${GRADLE_VERSION}
ENV PATH $PATH:$GRADLE_HOME/bin
RUN mkdir ~/.gradle
ENV GRADLE_USER_HOME ~/.gradle