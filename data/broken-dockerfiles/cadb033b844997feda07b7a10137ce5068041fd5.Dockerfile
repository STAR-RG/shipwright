#FROM scratch
#MAINTAINER tgic <farmer1992@gmail.com>
#
#COPY ./docker-wicket /docker-wicket
#
#EXPOSE 9999
#
#ENTRYPOINT ["/docker-wicket"]
#CMD ["-h"]

FROM golang:1.4
MAINTAINER tgic <farmer1992@gmail.com>


COPY . /go/src/github.com/tg123/docker-wicket

RUN go get github.com/tg123/docker-wicket


EXPOSE 9999

ENTRYPOINT ["/go/bin/docker-wicket"]

CMD ["-h"]
