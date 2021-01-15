FROM golang:onbuild

ENTRYPOINT ["/go/bin/app"]
CMD ["--help"]
