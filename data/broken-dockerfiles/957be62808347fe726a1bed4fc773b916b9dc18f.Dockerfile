# Dockerfile for a reveal.js environment with java, maven und docker cli

# Start it with
# docker run -it --rm \
#       -v /var/run/docker.sock:/var/run/docker.sock \
#       -v `pwd`:/slides \
#       -p 9000:9000 -p 57575:57575 -p 35279:35279 \
#       rhuss/docker-reveal
#
# See also /start.sh for possible options

FROM alpine:3.6

ENV MAVEN_VERSION 3.5.0
ENV MAVEN_BASE apache-maven-${MAVEN_VERSION}
ENV JAVA_HOME /usr/lib/jvm/default-jvm

#  RUN echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
RUN    apk update && \
    apk upgrade && \
    apk add \
          nodejs \
          nodejs-npm \
          python \
          python-dev \
          musl-dev \
          libffi-dev \
          openssl-dev \
          py-pip \
          gcc \
          g++ \
          openjdk8 \
          git \
          vim \
          docker \
          curl \
          bash \
          bash-completion && \
    pip install --upgrade pip && \
    pip install libsass && \
    npm install -g npm && \
    npm install -g grunt-cli bower yo generator-reveal && \
    wget http://www-eu.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/${MAVEN_BASE}-bin.tar.gz \
         -O /tmp/maven.tgz && \
    tar zxvf /tmp/maven.tgz && mv ${MAVEN_BASE} /maven && \
    ln -s /maven/bin/mvn /usr/bin/ && \
    rm /usr/bin/vi && ln -s /usr/bin/vim /usr/bin/vi && \
    rm /tmp/maven.tgz /var/cache/apk/* && \
    cd / && \
    git clone https://github.com/paradoxxxzero/butterfly && \
    mkdir -p /etc/butterfly/themes && \
    git clone https://github.com/paradoxxxzero/butterfly-themes /etc/butterfly/themes && \
    cd butterfly && \
    cp /etc/butterfly/themes/color-neon/style.sass butterfly/sass/main.sass && \
    cat /butterfly/butterfly/sass/_variables.sass | sed -e 's/font-size: 1em/font-size: 1.8em/' > /tmp/_v.sass && \
    mv /tmp/_v.sass /butterfly/butterfly/sass/_variables.sass && \
    sassc butterfly/sass/main.sass > butterfly/static/main.css && \
    python setup.py build && \
    python setup.py install && \
    cp /etc/terminfo/x/xterm-color /etc/terminfo/x/xterm-256color && \
    mkdir /slides && \
    adduser -D -h /slides -s /bin/ash -u 1000 yo && \
    git clone https://github.com/paradoxxxzero/butterfly-demos /butterfly/demos && \
    echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/profile 

RUN sed -e 's/\/bin\/ash/\/bin\/bash/' /etc/passwd > /tmp/,x && \
    mv /tmp/,x /etc/passwd

ADD docker/prompt.sh /etc/profile.d/prompt.sh
ADD docker/emacs.el /root/.emacs

ADD docker/start.sh /start.sh
ADD docker/cacerts /usr/lib/jvm/default-jvm/jre/lib/security/

# Workaround for making CTRL-C working again
ADD docker/shell_wrapper/reset_signals.c /tmp
ADD docker/shell_wrapper/ash_wrapper.sh /bin/ash_wrapper.sh
ADD docker/shell_wrapper/bash_wrapper.sh /bin/bash_wrapper.sh
RUN gcc /tmp/reset_signals.c -o /bin/reset_signals \
 && rm /bin/ash \
 && mv /bin/ash_wrapper.sh /bin/ash \
 && chmod 755 /bin/ash \
 && mv /bin/bash /bin/bash.orig \
 && mv /bin/bash_wrapper.sh /bin/bash \
 && chmod 755 /bin/bash

# ADD docker/butterfly /etc/butterfly
ADD docker/slides_init /slides_init
WORKDIR /slides_init
RUN rm -rf node_modules \
 && npm install
ADD docker/mime.types /etc/mime.types
RUN chmod 755 /usr/bin/mvn /start.sh

EXPOSE 9000 57575 35729

WORKDIR /slides
ENTRYPOINT ["sh", "/start.sh"]
