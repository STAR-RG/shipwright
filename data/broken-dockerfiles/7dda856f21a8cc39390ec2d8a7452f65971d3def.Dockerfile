FROM ubuntu:wily
MAINTAINER Michael Kleinhenz <m.kleinhenz@goquestor.com>

#### update/install packages ####
RUN echo 'force-unsafe-io' | tee /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | tee /etc/apt/apt.conf.d/no-cache && \
    DEBIAN_FRONTEND=noninteractive apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        software-properties-common curl && \
    DEBIAN_FRONTEND=noninteractive apt-get clean && DEBIAN_FRONTEND=noninteractive rm -rf /var/cache/apt/*

RUN DEBIAN_FRONTEND=noninteractive curl -sL https://deb.nodesource.com/setup_5.x | bash - 
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install nodejs

# install java
RUN \
  apt-get update && \
  apt-get install -y openjdk-7-jdk && \
  rm -rf /var/lib/apt/lists/*
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

# install android sdk to /opt/android and installing the needed 32bit dependencies
RUN DEBIAN_FRONTEND=noninteractive dpkg --add-architecture i386
RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy update
RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy install libncurses5:i386 libstdc++6:i386 zlib1g:i386
RUN curl -o /tmp/android.tgz http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
RUN tar xfz /tmp/android.tgz -C /opt
# use identifiers here: "build-tools-23.0.3" etc returned from android list sdk --extended --all instead of numbers (BECAUSE THEY CHANGE!)
#RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | /opt/android-sdk-linux/tools/android update sdk -u -a -t 1,4,6,27,49,50,52,53
RUN ( sleep 5 && while [ 1 ]; do sleep 1; echo y; done ) | /opt/android-sdk-linux/tools/android update sdk -u -a -t "tools","build-tools-23.0.3","platform-tools","android-23","addon-google_apis-google-23","extra-android-m2repository","extra-android-support","extra-google-google_play_services","extra-google-m2repository","extra-google-market_licensing","extra-google-market_apk_expansion","extra-google-play_billing"

# From here we load our application's code in, therefore the previous docker
# "layer" thats been cached will be used if possible
WORKDIR /opt/app

# get release zip from github, change archive url if a different release is needed
RUN curl -L -o /tmp/storyquest.tgz https://github.com/michaelkleinhenz/storyquest/releases/download/v3.0.5-beta/storyquest-3.0.5-beta.tar.gz
RUN tar xfz /tmp/storyquest.tgz -C /opt/app
RUN chmod a+x /opt/app/client-android/gradlew

EXPOSE 3001
EXPOSE 3000
EXPOSE 8080

# finally, start the application
WORKDIR /opt/app
CMD ["node", "storyquest.js"]
