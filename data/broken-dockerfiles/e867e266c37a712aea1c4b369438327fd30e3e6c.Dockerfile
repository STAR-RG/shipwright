FROM golang:1.7.1

ENV http_proxy="http://web-proxy.gre.hpecorp.net:8080" \
    https_proxy="http://web-proxy.gre.hpecorp.net:8080"

ENV APP_NAME forjj
ENV GLIDE_VERSION 0.12.1
ENV GLIDE_DOWNLOAD_URL https://github.com/Masterminds/glide/releases/download/v${GLIDE_VERSION}/glide-v${GLIDE_VERSION}-linux-amd64.tar.gz

RUN curl -fsSL "$GLIDE_DOWNLOAD_URL" -o glide.tar.gz \
    && tar -xzf glide.tar.gz \
    && mv linux-amd64/glide /usr/bin/ \
    && rm -r linux-amd64 \
    && rm glide.tar.gz
# Create a directory inside the container to store all our application and then
# make it the working directory.
RUN mkdir -p /go/src/${APP_NAME}
WORKDIR /go/src/${APP_NAME}

COPY . /go/src/${APP_NAME}

RUN glide up \
    && go build


