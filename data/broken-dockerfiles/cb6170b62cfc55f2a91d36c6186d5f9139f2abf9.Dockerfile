FROM ubuntu:12.04.5

RUN apt-get update -y && \
 apt-get install -y git-core g++ libbz2-dev \
  liblzma-dev libcrypto++-dev libpqxx3-dev scons libicu-dev \
  strace emacs ccache make gdb time automake libtool autoconf \
  bash-completion google-perftools libgoogle-perftools-dev \
  valgrind libACE-dev gfortran linux-tools uuid-dev liblapack-dev \
  libblas-dev libevent-dev flex bison pkg-config python-dev \
  python-numpy python-numpy-dev python-matplotlib libcppunit-dev \
  python-setuptools ant openjdk-7-jdk doxygen \
  libfreetype6-dev libpng-dev python-tk tk-dev python-virtualenv \
  sshfs rake ipmitool mm-common libsigc++-2.0-dev \
  libcairo2-dev libcairomm-1.0-dev cmake && \
 apt-get purge -y libcurl4-openssl-dev && \
 apt-get clean -y && \
 rm -vrf /var/lib/apt/lists/*

RUN git clone https://github.com/datacratic/platform-deps.git /platform-deps \
 && cd /platform-deps \
 && git submodule update --init \
 && export HOME="/opt" \
 && export PATH="/opt/local/bin:$PATH" \
 && export LD_LIBRARY_PATH="/opt/local/lib:$LD_LIBRARY_PATH" \
 && export PKG_CONFIG_PATH="/opt/local/lib/pkgconfig/:/opt/local/lib/pkg-config/:$PKG_CONFIG_PATH" \
 && cd /platform-deps \
 && make all \
 && rm -v /opt/local/bin/zookeeper \
 && mv -v /platform-deps/zookeeper /opt/local/bin/zookeeper \
 && rm -vrf /platform-deps

RUN useradd -d /opt -s /bin/bash rtbkit

RUN install -o rtbkit -d /opt/rtbkit \
 && su rtbkit -c "git clone https://github.com/onokonem/rtbkit.git /opt/rtbkit" \
 && cp -vp /opt/rtbkit/jml-build/sample.local.mk /opt/rtbkit/local.mk

RUN chown rtbkit /opt

RUN export LD_LIBRARY_PATH="/opt/local/lib:$LD_LIBRARY_PATH" \
 && export PKG_CONFIG_PATH="/opt/local/lib/pkgconfig/:/opt/local/lib/pkg-config/:$PKG_CONFIG_PATH" \
 && cd /opt/rtbkit \
 && su rtbkit -c "export PATH='/opt/local/bin:$PATH' && make dependencies"

RUN export LD_LIBRARY_PATH="/opt/local/lib:$LD_LIBRARY_PATH" \
 && export PKG_CONFIG_PATH="/opt/local/lib/pkgconfig/:/opt/local/lib/pkg-config/:$PKG_CONFIG_PATH" \
 && cd /opt/rtbkit \
 && su rtbkit -c "export PATH='/opt/local/bin:$PATH' && make compile"

#RUN export LD_LIBRARY_PATH="/opt/local/lib:$LD_LIBRARY_PATH" \
# && export PKG_CONFIG_PATH="/opt/local/lib/pkgconfig/:/opt/local/lib/pkg-config/:$PKG_CONFIG_PATH" \
# && cd /opt/rtbkit \
# && su rtbkit -c "export PATH='/opt/local/bin:$PATH' && make test"

CMD ["/bin/bash"]
