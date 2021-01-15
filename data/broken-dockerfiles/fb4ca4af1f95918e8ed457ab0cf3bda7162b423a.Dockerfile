FROM ubuntu:17.10

WORKDIR /root
ENV GOPATH=/root

RUN apt-get update && apt-get install -y golang-go golang-glide

ADD reflection proto fixtures src/github.com/komly/grpc-ui/reflection
ADD static src/github.com/komly/grpc-ui/static
ADD main.go glide.yaml glide.lock src/github.com/komly/grpc-ui/

RUN cd src/github.com/komly/grpc-ui && glide install
RUN go install github.com/komly/grpc-ui

CMD /root/bin/grpc-ui