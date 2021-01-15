FROM golang:alpine AS builder
RUN apk --no-cache add git make
ADD . /src/replicant
WORKDIR /src/replicant
RUN make build

FROM alpine
# FROM gcr.io/distroless/base
WORKDIR /app
COPY --from=builder /src/replicant/replicant /app/
CMD ["/app/replicant"]
