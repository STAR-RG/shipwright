FROM golang:1.9-alpine AS build
RUN apk add -U --no-cache git make
RUN go get github.com/gopherjs/gopherjs
RUN go get github.com/gopherjs/vecty
RUN go get github.com/go-humble/router
RUN go get github.com/goxjs/websocket
RUN go get github.com/gopherjs/websocket
RUN go get github.com/aaronarduino/goqrsvg
RUN go get github.com/nobonobo/vecty-chatapp
RUN cd $(go env GOPATH)/src/github.com/nobonobo/vecty-chatapp; \
    make build

FROM alpine:3.7
COPY --from=build /go/src/github.com/nobonobo/vecty-chatapp/dist/ /dist/
WORKDIR /dist
EXPOSE 8888
ENTRYPOINT [ "/dist/server" ]
