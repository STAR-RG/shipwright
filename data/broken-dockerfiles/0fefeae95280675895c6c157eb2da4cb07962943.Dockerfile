FROM centos:5
MAINTAINER James Pike version: 0.1

RUN yum install -y curl file gcc && curl -sSf http://static.rust-lang.org/rustup.sh | sed "s/https:/http:/" | sh -s - --disable-sudo -y --prefix=/usr
ADD . /lovely_touching
RUN cd lovely_touching && cargo build --release
