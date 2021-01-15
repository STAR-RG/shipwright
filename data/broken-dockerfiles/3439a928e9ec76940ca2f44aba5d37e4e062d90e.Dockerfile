FROM heroku/cedar:14

RUN useradd -d /app -m app
USER app
WORKDIR /app

ENV HOME /app
ENV PORT 3000

ENV GOVERSION 1.4.2
RUN mkdir -p /app/heroku/goroot && mkdir -p /app/src/gopath
RUN curl https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz \
           | tar xvzf - -C /app/heroku/goroot --strip-components=1

ENV GOROOT /app/heroku/goroot
ENV GOPATH /app/src/gopath
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH

RUN go get github.com/mitchellh/gox
RUN gox -os="darwin linux windows" -arch="386 amd64" -build-toolchain

RUN mkdir -p /app/heroku/mercurial
RUN curl -L http://mercurial.selenic.com/release/mercurial-3.4.tar.gz \
          | tar xvzf - -C /app/heroku/mercurial --strip-components=1 \
          && cd /app/heroku/mercurial \
          && make local 
ENV PATH /app/heroku/mercurial:$PATH

ONBUILD COPY . /app/src/gopath/src/github.com/root/gox-server
ONBUILD RUN cd /app/src/gopath/src/github.com/root/gox-server && go get ./...

WORKDIR /app/src/gopath/bin
ONBUILD EXPOSE 3000

ONBUILD RUN mkdir -p /app/.profile.d
ONBUILD RUN echo "export GOROOT=\"/app/heroku/goroot\"" > /app/.profile.d/gox-server.sh
ONBUILD RUN echo "export GOPATH=\"/app/src/gopath\"" >> /app/.profile.d/gox-server.sh
ONBUILD RUN echo "export PATH=\"$GOROOT/bin:$GOPATH/bin:/app/heroku/mercurial:\$PATH\"" >> /app/.profile.d/gox-server.sh
ONBUILD RUN echo "cd /app/src/gopath/bin" >> /app/.profile.d/gox-server.sh

