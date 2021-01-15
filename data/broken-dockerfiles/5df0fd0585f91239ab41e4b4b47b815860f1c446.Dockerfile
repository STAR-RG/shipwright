FROM golang:1.10

WORKDIR /go/src/github.com/DSiSc/justitia
COPY . .

RUN make fetch-deps
RUN go install -v ./...

EXPOSE 47768
EXPOSE 47780
EXPOSE 6060

CMD ["justitia"]
