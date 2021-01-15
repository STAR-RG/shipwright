FROM golang:1.8

ADD ./ /go/
RUN . /go/setup.sh && go install skel

ENTRYPOINT /go/bin/skel -router echo -profile yes

EXPOSE 8080
