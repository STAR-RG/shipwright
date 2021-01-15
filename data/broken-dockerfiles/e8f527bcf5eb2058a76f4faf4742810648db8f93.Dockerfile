# For reference, this is what travis currently runs

FROM ubuntu:trusty

RUN apt-get update -qq && apt-get install wget build-essential software-properties-common -y

COPY . /src
WORKDIR /src

# Environment variables from travis
ENV OCAML_VERSION=4.04
ENV OPAM_VERSION=1.2.2
ENV MODE=unix
ENV OPAM_INIT=true
ENV OPAM_SWITCH=system
ENV BASE_REMOTE=git://github.com/ocaml/opam-repository
ENV UPDATE_GCC_BINUTILS=0
ENV UBUNTU_TRUSTY=0
ENV INSTALL_XQUARTZ=true
ENV TRAVIS_OS_NAME=linux

RUN wget https://raw.githubusercontent.com/ocaml/ocaml-travisci-skeleton/master/.travis-ocaml.sh
RUN bash -e .travis-ocaml.sh
RUN bash -ex .travis-ci.sh
