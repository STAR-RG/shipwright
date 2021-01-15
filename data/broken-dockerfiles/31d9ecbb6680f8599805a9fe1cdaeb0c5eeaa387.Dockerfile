FROM golang:onbuild
RUN go get bitbucket.org/liamstask/goose/cmd/goose
EXPOSE 4000