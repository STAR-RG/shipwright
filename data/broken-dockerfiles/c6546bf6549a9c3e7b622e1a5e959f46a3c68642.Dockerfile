FROM ubuntu:18.04
# Run with `docker build --build-arg coda_version=<version>`
ARG coda_version
ARG deb_repo=stable
RUN echo "Building image with version $coda_version"

# Dependencies
RUN apt-get -y update && \
  DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install \
    strace \
    dumb-init \
    libssl1.1 \
    libprocps6 \
    libgmp10 \
    libgomp1 \
    libffi6 \
    apt-transport-https \
    ca-certificates \
    dnsutils \
    tzdata && \
  rm -rf /var/lib/apt/lists/*

# coda package
RUN echo "deb [trusted=yes] http://packages.o1test.net $deb_repo main" > /etc/apt/sources.list.d/coda.list \
  && apt-get update \
  && apt-get install --force-yes coda-testnet-postake-medium-curves=$coda_version -y

WORKDIR /root

RUN echo '#!/bin/bash -x\n\
mkdir -p .coda-config\n\
touch .coda-config/coda-prover.log\n\
touch .coda-config/coda-verifier.log\n\
coda "$@" 2>&1 >coda.log &\n\
coda_pid=$!\n\
tail -q -f coda.log -f .coda-config/coda-prover.log -f .coda-config/coda-verifier.log &\n\
tail_pid=$!\n\
wait "$coda_pid"\n\
echo "Coda process exited with status code $?"\n\
sleep 10\n\
kill "$tail_pid"\n\
exit 0'\
> init_coda.sh

RUN chmod +x init_coda.sh

ENTRYPOINT ["/usr/bin/dumb-init", "/root/init_coda.sh"]
