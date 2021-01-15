FROM jetbrains/upsource:@VERSION@

USER root

RUN apt-get update && \
    apt-get install -y apt-transport-https && \
    apt-get install -y curl && \
    apt-get install -y wget && \
# install python
    apt-get install -y python-pip && \
    apt-get install -y python3 && apt-get install -y python3-pip && \
# install php
    apt-get install -y libapache2-mod-php php gnupg && \
# install yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn && \
# install nodejs
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get install -y nodejs
    
# install Android tools
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
RUN mkdir ${ANDROID_HOME} && \
    wget https://dl.google.com/android/repository/tools_r25.2.5-linux.zip -O android-sdk-tools.zip && \
    unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} && \
    rm -f android-sdk-tools.zip && \
    mkdir -p ${ANDROID_HOME}/licenses
COPY ./android-licenses/*  ${ANDROID_HOME}/licenses/
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "platform-tools" && \
# Repeat two lines below for each SDK supported in your projects
    ${ANDROID_HOME}/tools/bin/sdkmanager "platforms;android-26" && \
    ${ANDROID_HOME}/tools/bin/sdkmanager "build-tools;26.0.0"

USER jetbrains
