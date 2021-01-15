FROM golang:1.5
ADD . /go/src/google-it 
WORKDIR /go/src/google-it 
RUN go get -d -v
RUN go install -v
RUN env
ENTRYPOINT ["google-it"]

