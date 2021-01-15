FROM golang:cross

ENV CGO_ENABLED 0

# Recompile the standard library without CGO
RUN go install -a std

RUN apt-get install -y -q git

# Declare the maintainer
MAINTAINER Millipede Team <business@millipede.io>

# For convenience, set an env variable with the path of the code
ENV APP_DIR /go/src/github.com/getmillipede/millipede-go
WORKDIR $APP_DIR

ADD . /go/src/github.com/getmillipede/millipede-go


# Compile the binary and statically link
RUN  GOOS=darwin   GOARCH=amd64          go build -a -v -ldflags '-d -w -s' -o /go/bin/millipede-go-Darwin-x86_64 ./cmd/millipede-go
RUN  GOOS=darwin   GOARCH=386            go build -a -v -ldflags '-d -w -s' -o /go/bin/millipede-go-Darwin-i386 ./cmd/millipede-go
RUN  GOOS=linux    GOARCH=386            go build -a -v -ldflags '-d -w -s' -o /go/bin/millipede-go-Linux-i386 ./cmd/millipede-go
RUN cp /go/bin/millipede-go-Linux-i386 /go/bin/millipede-go-Linux-x86_64
RUN  GOOS=linux    GOARCH=arm   GOARM=5  go build -a -v -ldflags '-d -w -s' -o /go/bin/millipede-go-Linux-arm ./cmd/millipede-go
RUN  GOOS=linux    GOARCH=arm   GOARM=6  go build -a -v -ldflags '-d -w -s' -o /go/bin/millipede-go-Linux-armv6 ./cmd/millipede-go
RUN  GOOS=linux    GOARCH=arm   GOARM=7  go build -a -v -ldflags '-d -w -s' -o /go/bin/millipede-go-Linux-armv7 ./cmd/millipede-go
RUN  GOOS=freebsd  GOARCH=amd64          go build -a -v -ldflags '-w -s'    -o /go/bin/millipede-go-Freebsd-x86_64 ./cmd/millipede-go
RUN  GOOS=freebsd  GOARCH=386            go build -a -v -ldflags '-d -w -s' -o /go/bin/millipede-go-Freebsd-i386 ./cmd/millipede-go
RUN  GOOS=freebsd  GOARCH=arm   GOARM=5  go build -a -v -ldflags '-d -w -s' -o /go/bin/millipede-go-Freebsd-arm ./cmd/millipede-go
RUN  GOOS=windows  GOARCH=amd64          go build -a -v -ldflags '-w -s'    -o /go/bin/millipede-go-Windows-x86_64.exe ./cmd/millipede-go
RUN  GOOS=linux    GOARCH=amd64          go build -a -v -ldflags '-w -s'    -o /go/bin/millipede-go-Linux-x86_64 ./cmd/millipede-go

#RUN GOOS=openbsd  GOARCH=amd64          go build -a -v -ldflags '-w -s'    -o /go/bin/millipede-go-Openbsd-x86_64 ./cmd/millipede-go
#RUN GOOS=openbsd  GOARCH=386            go build -a -v -ldflags '-d -w -s' -o /go/bin/millipede-go-Openbsd-i386 ./cmd/millipede-go
#RUN GOOS=openbsd  GOARCH=arm   GOARM=5  go build -a -v -ldflags '-d -w -s' -o /go/bin/millipede-go-Openbsd-arm ./cmd/millipede-go
#RUN GOOS=windows  GOARCH=386            go build -a -v -ldflags '-d -w -s' -o /go/bin/millipede-go-Windows-i386.exe ./cmd/millipede-go
#RUN GOOS=windows  GOARCH=arm   GOARM=5  go build -a -v -ldflags '-d -w -s' -o /go/bin/millipede-go-Windows-arm.exe ./cmd/millipede-go
