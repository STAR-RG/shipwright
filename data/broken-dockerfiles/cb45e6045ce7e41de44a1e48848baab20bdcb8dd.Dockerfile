## Build stage
FROM golang:1.9.4 as builder

# Set the working directory to the app directory
WORKDIR /go/src/captureorderfd

# Install godeps
RUN go get -u -v github.com/astaxie/beego
RUN go get -u -v github.com/beego/bee
RUN go get -d github.com/Microsoft/ApplicationInsights-Go/appinsights
RUN go get -u -v gopkg.in/mgo.v2
RUN go get -u -v github.com/streadway/amqp
RUN go get -u -v pack.ag/amqp
RUN go get gopkg.in/matryer/try.v1

# Copy the application files
COPY . .

# Build stage
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o captureorderfd .

## App stage
FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/captureorderfd .

# Define environment variables

# Challenge Logging
ENV TEAMNAME=team-azch

# Mongo/Cosmos
ENV MONGOHOST=
ENV MONGOUSER=
ENV MONGOPASSWORD=

# Expose the application on port 8080
EXPOSE 8080

# Set the entry point of the container to the bee command that runs the
# application and watches for changes
CMD ["./captureorderfd", "run"]
