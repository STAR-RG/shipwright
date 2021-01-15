FROM tensorflow/tensorflow

#Begin: install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends git
#End: install dependencies

#Begin: install golang
ENV GOLANG_VERSION 1.8.1
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 a579ab19d5237e263254f1eac5352efcf1d70b9dacadb6d6bb12b0911ede8994
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz && \
    echo "$GOLANG_DOWNLOAD_SHA256 golang.tar.gz" | sha256sum -c - && \
    tar -C /usr/local -xzf golang.tar.gz && \
    rm golang.tar.gz && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR "/go"
#End: install golang

#Begin: install tensorflow
ENV TENSORFLOW_LIB_GZIP libtensorflow-cpu-linux-x86_64-1.1.0.tar.gz
ENV TARGET_DIRECTORY /usr/local
RUN  curl -fsSL "https://storage.googleapis.com/tensorflow/libtensorflow/$TENSORFLOW_LIB_GZIP" -o $TENSORFLOW_LIB_GZIP && \
     sudo tar -C $TARGET_DIRECTORY -xzf $TENSORFLOW_LIB_GZIP && \
     rm -Rf $TENSORFLOW_LIB_GZIP
ENV LD_LIBRARY_PATH $TARGET_DIRECTORY/lib
ENV LIBRARY_PATH $TARGET_DIRECTORY/lib
RUN go get github.com/tensorflow/tensorflow/tensorflow/go
#End: install tensorflow