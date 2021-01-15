FROM alpine:3.7

ENV PROTOBUF_VERSION=3.6.1 \
    PROTOC_GEN_GO_VERSION=1.2.0 \
    PROTOC_GEN_GRPC_GATEWAY_VERSION=1.5.1
ENV GOPATH=/go \
    PATH=/go/bin/:$PATH
ENV PROTO_FILES=./proto/*.proto \
    PROTO_GO_OUT=./src

RUN apk add --no-cache \
    build-base \
    curl \
    automake \
    autoconf \
    libtool \
    git \
    zlib-dev

RUN mkdir -p /protobuf && \
    curl -L https://github.com/protocolbuffers/protobuf/archive/v${PROTOBUF_VERSION}.tar.gz | tar xvz --strip-components=1 -C /protobuf
RUN cd /protobuf && \
    ./autogen.sh && \
    ./configure --prefix=/usr && \
    make -j2 && make install

RUN apk add --no-cache go
RUN go get -u -v -ldflags '-w -s' \
    github.com/golang/protobuf/protoc-gen-go \
    github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger \
    github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway

WORKDIR /go/src/github.com/micnncim/docker-grpc-gateway
RUN go get github.com/golang/dep/cmd/dep
COPY Gopkg.toml Gopkg.lock ./
RUN dep ensure -v -vendor-only

# build go and protobuf
COPY . .
RUN protoc -I/protobuf -I. \
    -I${GOPATH}/src \
    -I${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
    --go_out=plugins=grpc:${PROTO_GO_OUT} \
    ${PROTO_FILES}
RUN protoc -I/protobuf -I. \
    -I${GOPATH}/src \
    -I${GOPATH}/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
    --grpc-gateway_out=logtostderr=true:${PROTO_GO_OUT} \
    ${PROTO_FILES}
RUN CGO_ENABLED=0 GOOS=linux go build -o /go/bin/docker-grpc-gateway \
    -ldflags="-w -s" -v \
    github.com/micnncim/docker-grpc-gateway

# light image for deployment
FROM alpine:3.7
RUN apk --no-cache add ca-certificates
COPY --from=0 /go/bin/docker-grpc-gateway /go/bin/docker-grpc-gateway
EXPOSE 8080
CMD  ["/go/bin/docker-grpc-gateway"]
