FROM golang:1.8

ENV GLIDE_VERSION v0.12.3

RUN go get -u github.com/jteeuwen/go-bindata/... \
    && go get github.com/alecthomas/gometalinter \
    && gometalinter --install --vendor \
    && go get golang.org/x/tools/cmd/goimports \
    && go get github.com/axw/gocov/gocov \
    && curl -Lo /tmp/glide.tgz https://github.com/Masterminds/glide/releases/download/$GLIDE_VERSION/glide-$GLIDE_VERSION-linux-amd64.tar.gz \
    && tar -C /usr/bin -xzf /tmp/glide.tgz --strip=1 linux-amd64/glide \
    && rm /tmp/glide.tgz

ENV CGO_ENABLED 0
ENV GOPATH /go:/toscalib
