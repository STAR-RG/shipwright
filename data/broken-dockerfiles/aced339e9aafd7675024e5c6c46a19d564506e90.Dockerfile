# Set up a docker machine that has all the tools to build teh senml spec

FROM ubuntu:latest
MAINTAINER Cullen Jennings <fluffy@iii.ca>

# set up basic build machine
RUN apt-get -y update

RUN apt-get -y upgrade 

RUN apt-get -y install tcsh

RUN apt-get install -y gcc make

# RUN apt-get install -y build-essential 

RUN apt-get install -y python-pip python-dev
RUN pip install --upgrade pip

RUN apt-get install -y default-jre  default-jdk

RUN apt-get install -y rubygems ruby-full ruby-json 
RUN gem install bundle

RUN apt-get install -y golang git 

# install XML2RFC
RUN pip install xml2rfc

# install Kramdown 
RUN gem install kramdown-rfc2629

# install senmlCat
RUN mkdir /go 
ENV PATH /go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV GOPATH /go
RUN go get github.com/cisco/senml
RUN ( cd /go/src/github.com/cisco/senml/cmd/senmlCat/ ; go install )

# install cddl to check cbor files
RUN gem install cddl

# instally tidy to relow XML 
RUN apt-get install -y tidy

RUN gem install libcbor cbor

# get hexdump 
RUN apt-get install -y bsdmainutils

VOLUME /senml
WORKDIR /senml

CMD [ "/usr/bin/make", "draft" ]

