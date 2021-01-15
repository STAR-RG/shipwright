FROM jamesandersen/alpine-golang-opencv3:edge
RUN apk --no-cache add git
WORKDIR /go/src/github.com/jamesandersen/gosudoku
COPY . .
RUN go get github.com/nytimes/gziphandler
RUN go-wrapper download   # "go get -d -v ./..."
RUN go-wrapper install    # "go install -v ./..."

FROM alpine:edge  
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk --no-cache add ca-certificates opencv-libs
RUN ln /usr/lib/libopencv_core.so.3.2.0 /usr/lib/libopencv_core.so \
    && ln /usr/lib/libopencv_highgui.so.3.2.0 /usr/lib/libopencv_highgui.so \
    && ln /usr/lib/libopencv_imgcodecs.so.3.2.0 /usr/lib/libopencv_imgcodecs.so \
    && ln /usr/lib/libopencv_imgproc.so.3.2.0 /usr/lib/libopencv_imgproc.so \
    && ln /usr/lib/libopencv_ml.so.3.2.0 /usr/lib/libopencv_ml.so \
    && ln /usr/lib/libopencv_objdetect.so.3.2.0 /usr/lib/libopencv_objdetect.so \
    && ln /usr/lib/libopencv_photo.so.3.2.0 /usr/lib/libopencv_photo.so
WORKDIR /root/
COPY --from=0 /go/bin/gosudoku .
COPY web ./web
# Set the PORT environment variable inside the container
ENV PORT 8080
# Expose port 8080 to the host so we can access our application
EXPOSE 8080

CMD ["./gosudoku"]  