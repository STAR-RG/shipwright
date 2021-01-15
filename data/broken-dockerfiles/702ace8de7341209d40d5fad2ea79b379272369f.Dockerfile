FROM golang:1.8-alpine

RUN mkdir -p /go/src/app
RUN apk add --no-cache git

WORKDIR /go/src/app
COPY . .

RUN go-wrapper download  
RUN go build -o ./bin/backend .

CMD ["./bin/backend"]