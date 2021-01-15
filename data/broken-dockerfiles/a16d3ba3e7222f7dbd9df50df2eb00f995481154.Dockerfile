FROM ubuntu

# curl and unzip are used by protobuf installer
RUN apt-get update && apt-get install -y git build-essential curl unzip autoconf libtool zlib1g-dev python-pip python-dev

# install protoc 3 from source
COPY installers/protoc.sh /tmp/install-protoc.sh
RUN chmod +x /tmp/install-protoc.sh
RUN /tmp/install-protoc.sh

# install go 1.6
RUN curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz
RUN tar -xvf go1.6.linux-amd64.tar.gz
RUN mv go /usr/local
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin/
RUN mkdir -p /go/pkg
RUN mkdir -p /go/bin
ENV GOPATH=/go

# protoc plugin for go
RUN go get -u github.com/golang/protobuf/protoc-gen-go
# plugin for generating the grpc gateway
RUN go get -u github.com/gengo/grpc-gateway/protoc-gen-grpc-gateway
# plugin for generating swagger from grpc
RUN go get -u github.com/gengo/grpc-gateway/protoc-gen-swagger

# install all the python things

# upgrade six to version required by grpcio
RUN pip install --upgrade six

# grpc bindings for python
RUN pip install grpcio
COPY installers/python-grpc.sh /tmp/install-python-grpc.sh
RUN chmod +x /tmp/install-python-grpc.sh
RUN /tmp/install-python-grpc.sh

# protoc plugin to generate python
COPY installers/python-grpc-hack.sh /tmp/install-python-grpc-hack.sh
RUN chmod +x /tmp/install-python-grpc-hack.sh
RUN /tmp/install-python-grpc-hack.sh
