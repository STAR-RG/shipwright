# -*- mode: conf -*-
FROM angr/angr
MAINTAINER Nobody

USER root
RUN apt-get update && apt-get install -y sudo sshfs bsdutils python3-dev \
                            libpq-dev pkg-config zlib1g-dev libtool libtool-bin wget automake autoconf coreutils bison libacl1-dev \
                            qemu-user qemu-kvm socat \
                            postgresql-client nasm binutils-multiarch llvm clang \
                            libpq-dev parallel libgraphviz-dev && \
    echo "angr ALL=NOPASSWD: ALL" > /etc/sudoers.d/angr

USER angr

# first clone, then install (for quicker builds from cache)
ARG EXTRA_REPOS="fidget angrop driller fuzzer tracer compilerex povsim rex farnsworth patcherex colorguard common-utils network_poll_creator patch_performance worker meister ambassador scriba"
RUN ~/angr-dev/setup.sh -C $EXTRA_REPOS && \
    ~/angr-dev/setup.sh -v -w -e angr peewee $EXTRA_REPOS && rm -rf wheels && \
    ~/angr-dev/setup.sh -v -w -p angr-pypy peewee $EXTRA_REPOS && rm -rf wheels && \
    ~/.virtualenvs/angr/bin/pip install pygraphviz && \
    ~/.virtualenvs/angr-pypy/bin/pip install pygraphviz

WORKDIR /home/angr
ENTRYPOINT [ "bash", "-i" ]
