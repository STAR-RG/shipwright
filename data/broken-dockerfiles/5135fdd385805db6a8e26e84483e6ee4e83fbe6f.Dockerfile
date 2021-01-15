FROM ubuntu:16.04
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yy make gcc-powerpc64le-linux-gnu  g++-powerpc64le-linux-gnu
RUN dpkg --add-architecture ppc64el
RUN sed -i -e 's/^deb /deb [arch=amd64] /' /etc/apt/sources.list
RUN echo 'deb [arch=ppc64el] http://ports.ubuntu.com/ubuntu-ports xenial main universe restricted' >> /etc/apt/sources.list
RUN echo 'deb [arch=ppc64el] http://ports.ubuntu.com/ubuntu-ports xenial-security main universe restricted' >> /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yy libncurses5:ppc64el libncurses-dev libdapl-dev:ppc64el
