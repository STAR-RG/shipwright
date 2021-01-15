FROM golang:1.6
ENV SRC_DIR /go/src/github.com/so0k/ecs-sample
RUN go get github.com/tools/godep \
    && go get golang.org/x/sys/unix

WORKDIR $SRC_DIR
COPY Godeps/Godeps.json $SRC_DIR/Godeps/Godeps.json
RUN godep restore

COPY . $SRC_DIR

#statically compile with CGO_ENABLED=0
RUN CGO_ENABLED=0 go build ./cmd/ecs-sample

EXPOSE 80
ENTRYPOINT ["./ecs-sample"]
