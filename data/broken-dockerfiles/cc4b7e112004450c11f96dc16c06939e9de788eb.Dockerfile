FROM centos:centos7
RUN yum install -y which docker golang git make

ARG GOPATH
ARG HOME
ENV GOPATH=${GOPATH:-/root/go} HOME=${HOME:-/root}

ADD . $GOPATH/src/github.com/beekhof/rss-operator
WORKDIR $GOPATH/src/github.com/beekhof/rss-operator
RUN make install

WORKDIR $GOPATH/src/github.com/beekhof/
RUN rm -rf rss-operator

CMD ["/usr/local/bin/rss-operator", "-alsologtostderr"]
