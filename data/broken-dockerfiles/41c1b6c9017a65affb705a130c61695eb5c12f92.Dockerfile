FROM rackhd/golang:1.7.1-wheezy

ADD ./bin/ipam /go/bin/ipam

ENTRYPOINT ["/go/bin/ipam"]
