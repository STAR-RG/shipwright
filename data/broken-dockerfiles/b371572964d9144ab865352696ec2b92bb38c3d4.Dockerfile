FROM centos:latest
MAINTAINER sehqlr

RUN yum update -y \
	&& yum upgrade -y \
	&& yum groupinstall -y "Development Tools" "Development Libraries" \
	&& yum install -y \
		git \
		golang \
		ruby \
		ruby-devel \
	&& yum clean all

ENV GOPATH /home
ENV PATH $PATH:$GOPATH/bin

RUN gem install fpm
RUN go get github.com/asteris-llc/hammer

VOLUME /out
WORKDIR /out
CMD hammer build
